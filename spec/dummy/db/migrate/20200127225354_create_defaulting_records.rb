class CreateDefaultingRecords < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :defaulting_records do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.string :name
      t.timestamps
    end
    
    add_index :defaulting_records, :name, unique: true
  end
end
