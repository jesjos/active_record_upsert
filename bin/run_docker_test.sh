#!/usr/bin/env bash
pushd spec/dummy
RAILS_ENV=test rails db:migrate
popd
RAILS_ENV=test bundle exec rspec
