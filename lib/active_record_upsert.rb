require 'active_record_upsert/version'

unless defined?(Arel)
  raise 'ActiveRecordUpsert has to be required after ActiveRecord/Arel'
end

unless defined?(ActiveRecord)
  raise 'ActiveRecordUpsert has to be required after ActiveRecord'
end

require 'active_record_upsert/arel'
require 'active_record_upsert/active_record'

require 'active_record_upsert/compatibility/rails51.rb' if Rails.version >= '5.1.0' && Rails.version < '5.2.0.rc1'
require 'active_record_upsert/compatibility/rails50.rb' if Rails.version >= '5.0.0' && Rails.version < '5.1.0'

module ActiveRecordUpsert
  # Your code goes here...
end
