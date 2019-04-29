class AddYearToVehicles < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :year, :integer
    add_index :vehicles, :year, unique: true
    add_index :vehicles, [:make], unique: true, where: "year IS NULL", name: 'partial_index_vehicles_on_make_without_year'
  end
end
