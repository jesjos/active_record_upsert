class CreateMyRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :my_records do |t|
      t.string :name
      t.integer :wisdom
      t.timestamps

      t.index :wisdom, unique: true
    end
  end
end
