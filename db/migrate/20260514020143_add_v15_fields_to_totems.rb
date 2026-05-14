class AddV15FieldsToTotems < ActiveRecord::Migration[8.1]
  def change
    add_column :totems, :character_description, :string, limit: 140
    add_column :totems, :neighborhood, :string
    add_column :totems, :city_slug, :string, default: "stpete", null: false
    add_index  :totems, :city_slug
  end
end
