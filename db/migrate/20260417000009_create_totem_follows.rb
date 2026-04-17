class CreateTotemFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :totem_follows do |t|
      t.references :user, null: false, foreign_key: true
      t.references :totem, null: false, foreign_key: true
      t.boolean :notify_new_event, null: false, default: true
      t.boolean :notify_reminder, null: false, default: true
      t.timestamps
    end

    add_index :totem_follows, [ :user_id, :totem_id ], unique: true
  end
end
