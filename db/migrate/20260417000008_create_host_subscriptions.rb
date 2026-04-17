class CreateHostSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :host_subscriptions do |t|
      t.bigint :user_id, null: false
      t.bigint :host_user_id, null: false
      t.boolean :notify_new_event, null: false, default: true
      t.boolean :notify_reminder, null: false, default: true
      t.timestamps
    end

    add_index :host_subscriptions, [ :user_id, :host_user_id ], unique: true
    add_foreign_key :host_subscriptions, :users, column: :user_id
    add_foreign_key :host_subscriptions, :users, column: :host_user_id
  end
end
