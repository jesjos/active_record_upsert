FROM quay.io/travisci/travis-ruby
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get install ruby2.3 ruby2.3-dev
RUN ruby --version
 
ENV BUNDLE_GEMFILE=/app/Gemfile.docker
RUN gem install nokogiri
RUN gem install bundler
COPY Gemfile* *.gemspec /app/
RUN mkdir -p /app/lib/active_record_upsert
COPY lib/active_record_upsert/version.rb /app/lib/active_record_upsert/
WORKDIR /app
RUN bundle install
COPY . /app
CMD bin/run_docker_test.sh


