class CreateCheckIns < ActiveRecord::Migration[8.1]
  def change
    create_table :check_ins do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.datetime :checked_in_at, null: false
      t.timestamps
    end

    add_index :check_ins, [ :user_id, :event_id ], unique: true
  end
end
