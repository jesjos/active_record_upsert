$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'active_record_upsert'

require 'setup'

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      database: 'upsert_test'
    )

    unless ActiveRecord::Base.connection.data_source_exists?(:my_records)
      ActiveRecord::Base.connection.create_table(:my_records) do |t|
        t.string :name
        t.integer :wisdom
        t.timestamps
      end
      ActiveRecord::Base.connection.add_index :my_records, :wisdom, unique: true
    end

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
