class CreateTotems < ActiveRecord::Migration[8.1]
  def change
    create_table :totems do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.text :location_description
      t.boolean :active, null: false, default: false
      t.string :qr_url
      t.timestamps
    end

    add_index :totems, :slug, unique: true
    add_index :totems, :active
  end
end
