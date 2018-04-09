require 'active_record_upsert/version'

unless defined?(Arel)
  raise 'ActiveRecordUpsert has to be required after ActiveRecord/Arel'
end

unless defined?(ActiveRecord)
  raise 'ActiveRecordUpsert has to be required after ActiveRecord'
end

require 'active_record_upsert/arel'
require 'active_record_upsert/active_record'

version = defined?(Rails) ? Rails.version : ActiveRecord.version.to_s

require 'active_record_upsert/compatibility/rails51.rb' if version >= '5.1.0' && version < '5.2.0'
require 'active_record_upsert/compatibility/rails50.rb' if version >= '5.0.0' && version < '5.1.0'

module ActiveRecordUpsert
  # Your code goes here...
end
