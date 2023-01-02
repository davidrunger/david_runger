FROM ruby:3.1.3

# Install nodejs on the default ruby 3 image
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
      apt-get install -y nodejs build-essential && \
      npm install -g yarn@1.22.19

WORKDIR /app

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
COPY package.json ./package.json
COPY yarn.lock ./yarn.lock
RUN bundle install
RUN yarn install

COPY . .

CMD ["bin/rails", "console"]
