class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :host, null: false, foreign_key: true
      t.references :totem_page, null: true, foreign_key: true
      t.string :title, null: false, default: ""
      t.text :description
      t.string :activity_type
      t.string :category
      t.string :location_name
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.datetime :start_time, null: false
      t.integer :scheduled_duration_min, null: false, default: 90
      t.datetime :extended_until
      t.string :recurrence_rule
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :events, :start_time
    add_index :events, :status
  end
end
