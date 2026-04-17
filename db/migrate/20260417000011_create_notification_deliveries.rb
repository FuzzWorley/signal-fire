class CreateNotificationDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.string :source_type, null: false
      t.datetime :sent_at
      t.datetime :opened_at
      t.timestamps
    end

    add_index :notification_deliveries, [ :user_id, :event_id, :notification_type ]
  end
end
