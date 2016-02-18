require 'active_record_upsert/arel/nodes/on_conflict_action'
require 'active_record_upsert/arel/nodes/insert_statement'

Dir.glob(File.join(__dir__, 'arel/**/*.rb')) do |f|
  require f
end
