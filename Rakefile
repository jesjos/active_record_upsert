require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'active_record'
RSpec::Core::RakeTask.new(:spec)

task :setup_and_run_spec do |rake_task|
  puts "<:#{rake_task.name}> Ensuring database is prepared..."

  # Configure Rails Environment
  ENV['RAILS_ENV'] = 'test'
  ENV['DATABASE_URL'] ||= 'postgresql://localhost/upsert_test'
  require 'active_record/connection_adapters/postgresql_adapter'

  require File.expand_path('../spec/dummy/config/environment.rb', __FILE__)

  if Rails.version >= '5.2.0'
    ActiveRecord::Base.connection.migrations_paths << 'spec/dummy/db/migrate'
  end

  include ActiveRecord::Tasks
  DatabaseTasks.db_dir = 'spec/dummy/db'
  DatabaseTasks.drop_current
  DatabaseTasks.create_current
  DatabaseTasks.migrate

  Rake::Task['spec'].invoke
end

task default: :setup_and_run_spec
