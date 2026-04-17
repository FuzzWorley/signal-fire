class CreateAnonymousCheckInCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :anonymous_check_in_counts do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.integer :count, null: false, default: 0
      t.timestamps
    end
  end
end
