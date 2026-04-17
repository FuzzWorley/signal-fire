class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :slug, null: false
      t.references :totem, null: false, foreign_key: true
      t.bigint :host_user_id, null: false
      t.string :title, null: false
      t.text :description
      t.text :community_norms
      t.string :recurrence_type, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :chat_url, null: false
      t.string :chat_platform, null: false
      t.string :status, null: false, default: "active"
      t.boolean :created_by_admin, null: false, default: false
      t.timestamps
    end

    add_index :events, :slug, unique: true
    add_index :events, :host_user_id
    add_index :events, :status
    add_index :events, :start_time
    add_foreign_key :events, :users, column: :host_user_id
  end
end
