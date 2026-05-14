class AddV15FieldsToHostProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :host_profiles, :host_story, :text
    add_column :host_profiles, :slug, :string
    add_index  :host_profiles, :slug, unique: true
  end
end
