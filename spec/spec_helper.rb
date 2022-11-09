$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'database_cleaner'
require 'securerandom'

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require 'active_record/connection_adapters/postgresql_adapter'
ENV['DATABASE_URL'] ||= 'postgresql://localhost/upsert_test'

require File.expand_path('../../spec/dummy/config/environment.rb', __FILE__)

RSpec.configure do |config|
  config.disable_monkey_patching!
  if Rails.version.is_a?(String) && Rails.version.chars.first.to_i < 6
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.around(:each) do |example|
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  else
    config.after do
      ActiveRecord::Tasks::DatabaseTasks.truncate_all
    end
  end
end
