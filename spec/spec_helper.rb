$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'active_record_upsert'
require 'database_cleaner'

class MyRecord < ActiveRecord::Base
  before_save :before_s
  after_save :after_s
  before_create :before_c
  after_create :after_c
  after_commit :after_com

  def before_s
  end

  def after_s
  end

  def before_c
  end

  def after_c
  end

  def after_com
  end
end  

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'upsert_test'
)

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
