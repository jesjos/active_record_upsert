#!/usr/bin/env bash
pushd spec/dummy
DATABASE_URL=postgresql://localhost/upsert_test RAILS_ENV=test rails db:migrate
popd
RAILS_ENV=test bundle exec rspec
