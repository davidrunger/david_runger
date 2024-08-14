#!/usr/bin/env bash

# From script linked at (plus some modifications):
# https://pentacent.medium.com/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

# shellcheck disable=SC2128

domains=(davidrunger.com www.davidrunger.com)
rsa_key_size=4096
data_path="./ssl-data/certbot"
email="davidjrunger@gmail.com" # Adding a valid address is strongly recommended

if [ -z "$staging" ] || { [ "$staging" != "0" ] && [ "$staging" != "1" ] ; } ; then
  echo 'Specify either staging=1 (to test with less rate limiting)'
  echo 'or staging=0 (to go for real) as an env var prefix.'
  exit 1
fi

if [ -d "$data_path" ]; then
  read -r -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Temporarily commenting out problematic line ..."
sed -i 's|^\s\+\(ssl_trusted_certificate\s\)|    # \1|' config/nginx/sites-enabled/davidrunger.com.conf
echo

echo "### Starting nginx ..."
docker compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo


echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ "$staging" != "0" ]; then staging_arg="--test-cert"; fi

docker compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/_letsencrypt \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Uncommenting temporarily commented-out line ..."
sed -i 's|^\s\+# \(ssl_trusted_certificate\s\)|    \1|' config/nginx/sites-enabled/davidrunger.com.conf
echo

echo "### Reloading nginx ..."
docker compose exec nginx nginx -s reload
