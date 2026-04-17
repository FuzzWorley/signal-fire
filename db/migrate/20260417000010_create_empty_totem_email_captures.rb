class CreateEmptyTotemEmailCaptures < ActiveRecord::Migration[8.1]
  def change
    create_table :empty_totem_email_captures do |t|
      t.references :totem, null: false, foreign_key: true
      t.string :email, null: false
      t.datetime :captured_at, null: false
      t.timestamps
    end
  end
end
