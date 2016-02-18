require 'active_record/connection_adapters/postgresql_adapter'

Dir.glob(File.join(__dir__, 'active_record/**/*.rb')) do |f|
  require f
end
