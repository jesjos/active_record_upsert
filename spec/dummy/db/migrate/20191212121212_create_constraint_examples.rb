class CreateConstraintExamples < ActiveRecord::Migration[5.0]
  def up
    create_table :constraint_examples do |t|
      t.string :name
      t.integer :age
      t.string :color
      t.timestamps
    end
    
    execute <<~SQL
      ALTER TABLE constraint_examples ADD CONSTRAINT my_unique_constraint UNIQUE (name, age);
    SQL
  end
  
  def down
    drop_table :constraint_examples
  end
end
