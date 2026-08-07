#!/usr/bin/env bash
pushd spec/dummy
DATABASE_URL=postgresql://db/activerecord_upsert_test RAILS_ENV=test bundle exec rails db:setup db:migrate
popd
DATABASE_URL=postgresql://db/activerecord_upsert_test RAILS_ENV=test bundle exec rspec
