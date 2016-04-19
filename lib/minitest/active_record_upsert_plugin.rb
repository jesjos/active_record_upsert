module Minitest
  def self.plugin_active_record_upsert_options(opts, _options)
    opts.on('--pattern') do
      $stderr.puts 'Yeah, man, --pattern is from RSpec, ignore it.'
    end
  end
end