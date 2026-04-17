class CreateHostTotemAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :host_totem_assignments do |t|
      t.references :host_user, null: false, foreign_key: { to_table: :users }
      t.references :totem, null: false, foreign_key: true
      t.datetime :assigned_at
      t.bigint :assigned_by_admin_id
      t.timestamps
    end

    add_index :host_totem_assignments, [ :host_user_id, :totem_id ], unique: true
    add_foreign_key :host_totem_assignments, :users, column: :assigned_by_admin_id
  end
end
