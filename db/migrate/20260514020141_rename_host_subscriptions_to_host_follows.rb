class RenameHostSubscriptionsToHostFollows < ActiveRecord::Migration[8.1]
  def change
    rename_table :host_subscriptions, :host_follows
  end
end
