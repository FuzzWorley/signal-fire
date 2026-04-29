class AddMagicLinkTokenToHostProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :host_profiles, :magic_link_token, :string
    add_column :host_profiles, :magic_link_token_expires_at, :datetime
  end
end
