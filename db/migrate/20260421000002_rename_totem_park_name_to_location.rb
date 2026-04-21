class RenameTotemParkNameToLocation < ActiveRecord::Migration[8.1]
  def change
    rename_column :totems, :park_name, :location
  end
end
