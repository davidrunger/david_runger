FROM ruby:3.1.3

# Install nodejs on the default ruby 3 image
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
      apt-get install -y nodejs build-essential && \
      npm install -g pnpm@8.5.1

WORKDIR /app

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
COPY package.json ./package.json
COPY pnpm-lock.yaml ./pnpm-lock.yaml
RUN bundle install
RUN pnpm install

COPY . .

CMD ["bin/rails", "console"]
