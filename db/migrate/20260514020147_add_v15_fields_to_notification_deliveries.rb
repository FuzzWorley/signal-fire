class AddV15FieldsToNotificationDeliveries < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_deliveries, :notification_subtype, :string

    # Rename source_type stored values to match renamed models
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE notification_deliveries SET source_type = 'host_follow'    WHERE source_type = 'host_subscription';
          UPDATE notification_deliveries SET source_type = 'totem_favorite' WHERE source_type = 'totem_follow';
        SQL
      end
      dir.down do
        execute <<~SQL
          UPDATE notification_deliveries SET source_type = 'host_subscription' WHERE source_type = 'host_follow';
          UPDATE notification_deliveries SET source_type = 'totem_follow'      WHERE source_type = 'totem_favorite';
        SQL
      end
    end
  end
end
