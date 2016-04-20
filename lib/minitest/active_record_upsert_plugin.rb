module Minitest
  # In order to make Rails' minitest railtie understand the :spec Rake task's
  # generated --pattern ARGV option, this little plugin adds a noop option
  # for it - this avoids errors.
  def self.plugin_active_record_upsert_options(opts, _options)
    opts.on('--pattern') # --pattern is from RSpec, ignore it.
  end
end
