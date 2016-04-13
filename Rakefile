require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "active_record"
RSpec::Core::RakeTask.new(:spec)

task :setup_and_run_spec do |t|
  puts t.name
  puts 'Ensure database is prepped.'
  
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

  Rake::Task['spec'].invoke
end

task default: :setup_and_run_spec
