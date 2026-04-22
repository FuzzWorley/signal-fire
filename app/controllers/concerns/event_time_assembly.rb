module EventTimeAssembly
  private

  def assemble_times(attrs)
    recurrence_type   = attrs[:recurrence_type]
    start_time_of_day = attrs.delete(:start_time_of_day)
    end_time_of_day   = attrs.delete(:end_time_of_day)
    start_day_of_week = attrs.delete(:start_day_of_week)
    start_date_raw    = attrs.delete(:start_date)

    return attrs unless start_time_of_day.present? && end_time_of_day.present?

    base_date = if recurrence_type == "weekly"
      day_of_week = start_day_of_week.to_i
      today       = Time.zone.today
      days_ahead  = (day_of_week - today.wday) % 7
      today + days_ahead.days
    else
      start_date_raw.present? ? Date.parse(start_date_raw) : nil
    end

    return attrs unless base_date

    attrs[:start_time] = Time.zone.parse("#{base_date} #{start_time_of_day}")
    attrs[:end_time]   = Time.zone.parse("#{base_date} #{end_time_of_day}")
    attrs
  end
end
