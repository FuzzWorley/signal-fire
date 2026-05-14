module EventTimeAssembly
  private

  BYDAY_MAP = %w[SU MO TU WE TH FR SA].freeze

  def assemble_times(attrs)
    recurrence_type   = attrs.delete(:recurrence_type)
    start_time_of_day = attrs.delete(:start_time_of_day)
    end_time_of_day   = attrs.delete(:end_time_of_day)
    start_day_of_week = attrs.delete(:start_day_of_week)
    start_date_raw    = attrs.delete(:start_date)

    return attrs unless start_time_of_day.present? && end_time_of_day.present?

    if recurrence_type == "weekly"
      day_of_week = start_day_of_week.to_i
      today       = Time.zone.today
      days_ahead  = (day_of_week - today.wday) % 7
      base_date   = today + days_ahead.days
      attrs[:recurrence_rule] = "FREQ=WEEKLY;BYDAY=#{BYDAY_MAP[day_of_week]}"
    else
      base_date = start_date_raw.present? ? Date.parse(start_date_raw) : nil
      attrs[:recurrence_rule] = nil
    end

    return attrs unless base_date

    attrs[:start_time] = Time.zone.parse("#{base_date} #{start_time_of_day}")
    attrs[:end_time]   = Time.zone.parse("#{base_date} #{end_time_of_day}")
    attrs[:end_time] += 1.day if attrs[:end_time] <= attrs[:start_time]
    attrs
  end
end
