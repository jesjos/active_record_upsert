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

require 'active_record_upsert/compatibility/rails70.rb' if version >= '7.0.0' && version < '8.0.0'
require 'active_record_upsert/compatibility/rails60.rb' if version >= '6.0.0' && version < '6.2.0'

module ActiveRecordUpsert
  # Your code goes here...
end
