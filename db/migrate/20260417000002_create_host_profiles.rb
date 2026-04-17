class CreateHostProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :host_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :display_name
      t.text :blurb
      t.string :invite_status, null: false, default: "invited"
      t.datetime :invited_at
      t.datetime :invite_accepted_at
      t.string :invitation_token
      t.datetime :invitation_token_expires_at
      t.string :timezone
      t.timestamps
    end

    add_index :host_profiles, :invitation_token, unique: true
  end
end
