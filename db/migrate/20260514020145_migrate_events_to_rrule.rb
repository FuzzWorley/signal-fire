class MigrateEventsToRrule < ActiveRecord::Migration[8.1]
  def up
    add_column :events, :recurrence_rule, :string

    execute <<~SQL
      UPDATE events
      SET recurrence_rule = 'FREQ=WEEKLY;BYDAY=' ||
        CASE EXTRACT(DOW FROM start_time)
          WHEN 0 THEN 'SU'
          WHEN 1 THEN 'MO'
          WHEN 2 THEN 'TU'
          WHEN 3 THEN 'WE'
          WHEN 4 THEN 'TH'
          WHEN 5 THEN 'FR'
          WHEN 6 THEN 'SA'
        END
      WHERE recurrence_type = 'weekly'
    SQL

    remove_column :events, :recurrence_type
  end

  def down
    add_column :events, :recurrence_type, :string

    execute <<~SQL
      UPDATE events
      SET recurrence_type = CASE
        WHEN recurrence_rule IS NOT NULL THEN 'weekly'
        ELSE 'one_time'
      END
    SQL

    remove_column :events, :recurrence_rule
  end
end

