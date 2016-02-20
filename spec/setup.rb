ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'upsert_test'
)

unless ActiveRecord::Base.connection.table_exists?(:my_records)
  ActiveRecord::Base.connection.create_table(:my_records) do |t|
    t.string :name
    t.timestamps
  end
end

class MyRecord < ActiveRecord::Base
  before_save :before_s
  after_save :after_s
  before_create :before_c
  after_create :after_c

  def before_s
  end

  def after_s
  end

  def before_c
  end

  def after_c
  end
end
