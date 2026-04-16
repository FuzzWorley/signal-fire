class CreateHosts < ActiveRecord::Migration[8.1]
  def change
    create_table :hosts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false, default: ""
      t.text :bio
      t.text :application_notes
      t.references :approved_by_admin, foreign_key: { to_table: :users }
      t.datetime :approved_at

      t.timestamps
    end

  end
end
