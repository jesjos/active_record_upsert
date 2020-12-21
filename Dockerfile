FROM ruby:latest
RUN ruby --version

ENV BUNDLE_GEMFILE=/app/Gemfile.docker
RUN gem install bundler nokogiri
COPY Gemfile* *.gemspec /app/
RUN mkdir -p /app/lib/active_record_upsert
COPY lib/active_record_upsert/version.rb /app/lib/active_record_upsert/
WORKDIR /app
RUN bundle install
COPY . /app
CMD bin/run_docker_test.sh

