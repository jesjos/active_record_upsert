class CreateVehicles < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicles do |t|
      t.integer :wheels_count
      t.string :name

      t.timestamps
    end
  end
end
