class AddAllToNotificationPrefs < ActiveRecord::Migration[8.0]
  def up
    User.where("notification_prefs->>'all' IS NULL").update_all(
      "notification_prefs = notification_prefs || '{\"all\": true}'"
    )
    change_column_default :users, :notification_prefs,
      from: { "new_event" => true, "reminder" => true },
      to: { "new_event" => true, "reminder" => true, "all" => true }
  end

  def down
    User.update_all(
      "notification_prefs = notification_prefs - 'all'"
    )
    change_column_default :users, :notification_prefs,
      from: { "new_event" => true, "reminder" => true, "all" => true },
      to: { "new_event" => true, "reminder" => true }
  end
end
