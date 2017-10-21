FROM ruby:2
RUN apt-get update -qq && apt-get install -y build-essential libmysqlclient-dev
RUN mkdir /brain
WORKDIR /brain
ADD Gemfile /brain/Gemfile
ADD Gemfile.lock /brain/Gemfile.lock
RUN bundle install --deployment
ADD . /brain
ENV PATH "/brain/bin:${PATH}"
