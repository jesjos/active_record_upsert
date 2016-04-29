$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'active_record_upsert'
require 'database_cleaner'

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
ENV['DATABASE_URL'] ||= 'postgresql://localhost/active_record_upsert_test'

require File.expand_path('../../spec/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../spec/dummy/db/migrate', __FILE__)]

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
