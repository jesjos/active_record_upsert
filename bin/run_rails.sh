#!/usr/bin/env bash
pushd spec/dummy
RAILS_ENV=test bundle exec rails $@
popd
