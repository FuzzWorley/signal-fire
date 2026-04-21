class SplitTotemLocationIntoParkAndSublocation < ActiveRecord::Migration[8.1]
  def change
    add_column :totems, :park_name, :string
    add_column :totems, :sublocation, :string
    remove_column :totems, :location_description, :text
  end
end
