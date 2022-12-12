FROM ruby:2.7.2

RUN apt-get -y update
RUN apt-get -y install git-all
RUN gem install bundler:2.2.10
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN mkdir -p /app

COPY . /app

WORKDIR /app

RUN bundle install

ENTRYPOINT ["sh", "entrypoint.sh"]

