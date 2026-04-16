class CreateTotemPages < ActiveRecord::Migration[8.1]
  def change
    create_table :totem_pages do |t|
      t.references :host, null: false, foreign_key: true
      t.string :slug, null: false
      t.string :group_name, null: false, default: ""
      t.text :description
      t.text :norms_text
      t.text :schedule_text
      t.string :whatsapp_link
      t.string :signal_link
      t.string :qr_code_url
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :totem_pages, :slug, unique: true
    add_index :totem_pages, :published
  end
end
