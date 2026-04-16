class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone_number
      t.string :email
      t.string :google_uid
      t.string :role, null: false, default: "attendee"
      t.string :host_status, null: false, default: "none"
      t.integer :radius_km, null: false, default: 10
      t.jsonb :notification_prefs, null: false, default: { "following" => true, "discover" => true }
      t.jsonb :interests, null: false, default: {}

      t.timestamps
    end

    add_index :users, :phone_number, unique: true
    add_index :users, :email, unique: true
    add_index :users, :google_uid, unique: true
    add_index :users, :host_status
  end
end
