class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.boolean :active
      t.timestamps
    end

     add_index :accounts, :name, unique: true, where: "active IS TRUE"

     add_reference :vehicles, :account
  end
end
