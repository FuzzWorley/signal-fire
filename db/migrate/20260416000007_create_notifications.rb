class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :event, null: false, foreign_key: true
      t.references :host, null: false, foreign_key: true
      t.string :title, null: false, default: ""
      t.text :body
      t.datetime :send_at, null: false
      t.datetime :sent_at
      t.string :status, null: false, default: "scheduled"
      t.string :tier, null: false, default: "following"
      t.jsonb :sent_to_user_ids, null: false, default: []

      t.timestamps
    end

    add_index :notifications, :send_at
    add_index :notifications, :status
  end
end
