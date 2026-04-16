class CreateReputations < ActiveRecord::Migration[8.1]
  def change
    create_table :reputations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :host, null: false, foreign_key: true
      t.integer :total_count, null: false, default: 0
      t.jsonb :by_category, null: false, default: {}

      t.timestamps
    end

    add_index :reputations, [ :user_id, :host_id ], unique: true
  end
end
