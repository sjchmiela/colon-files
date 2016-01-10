FROM ruby:2.2.3

## Add app code and install dependencies
RUN gem install bundler
ADD app/Gemfile /opt/app/Gemfile
RUN cd /opt/app; bundle install
COPY app/ /opt/app
