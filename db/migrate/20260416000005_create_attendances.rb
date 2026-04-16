class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :host, null: false, foreign_key: true
      t.string :category
      t.datetime :checked_in_at, null: false

      t.timestamps
    end

    add_index :attendances, [ :user_id, :event_id ], unique: true
  end
end
