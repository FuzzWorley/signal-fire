module Admin::EventsHelper
  def event_display_status(event)
    return :cancelled if event.cancelled?
    return :live      if event.active_now?
    event.next_occurrence > Time.current ? :upcoming : :past
  end

  def event_when_label(event)
    occ = event.next_occurrence
    if occ.to_date == Time.zone.today
      "Today · #{occ.strftime('%-I:%M %p')}"
    elsif event.weekly?
      "#{occ.strftime('%a')} · #{occ.strftime('%-I:%M %p')}"
    else
      "#{occ.strftime('%a · %b %-d · %-I:%M %p')}"
    end
  end
end
