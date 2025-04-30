FROM ruby:3.0.0

RUN apt-get -y update
RUN apt-get install -y git-all libraptor2-0 libraptor2-dev 

RUN gem install bundler:2.2.31
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN mkdir -p /app

COPY . /app

WORKDIR /app

RUN bundle install

ENTRYPOINT ["sh", "entrypoint.sh"]

