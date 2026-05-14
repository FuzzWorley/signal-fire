class CreateUserHostFirstSeens < ActiveRecord::Migration[8.1]
  def change
    create_table :user_host_first_seens do |t|
      t.references :user,         null: false, foreign_key: true
      t.bigint     :host_user_id, null: false
      t.datetime   :first_seen_at, null: false
      t.timestamps
    end

    add_foreign_key :user_host_first_seens, :users, column: :host_user_id
    add_index :user_host_first_seens, [ :user_id, :host_user_id ], unique: true
  end
end

