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

if version >= '7.0.0'
  require 'active_record_upsert/compatibility/rails70.rb'
elsif version >= '6.0.0' && version < '6.2.0'
  require 'active_record_upsert/compatibility/rails60.rb'
end

module ActiveRecordUpsert
  # Your code goes here...
end
