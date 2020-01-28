class CreateDefaultingConstraintExamples < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :defaulting_constraint_examples do |t|
      t.string :name
      t.integer :age
      t.uuid :color, null: false, default: "gen_random_uuid()"
      t.timestamps
    end
    
    execute <<~SQL
      ALTER TABLE defaulting_constraint_examples ADD CONSTRAINT my_defaulting_unique_constraint UNIQUE (name, age);
    SQL
  end
  
  def down
    drop_table :defaulting_constraint_examples
  end
end
