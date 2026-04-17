class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :name
      t.string :auth_method, null: false, default: "email"
      t.boolean :is_host, null: false, default: false
      t.boolean :is_admin, null: false, default: false
      t.string :push_token
      t.jsonb :notification_prefs, null: false, default: { new_event: true, reminder: true }
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
