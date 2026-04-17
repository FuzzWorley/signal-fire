class Totems::CheckInsController < ApplicationController
  def create
    @totem = Totem.find_by!(slug: params[:slug])
    @event = @totem.events.find_by!(slug: params[:event_slug])

    unless @event.active_now?
      return redirect_to totem_event_path(@totem.slug, @event.slug),
                         alert: "Check-in is only available within 30 minutes of the event."
    end

    cookie_key = "checked_in_event_#{@event.id}"
    unless cookies[cookie_key]
      record = AnonymousCheckInCount.find_or_create_by!(event: @event)
      AnonymousCheckInCount.increment_counter(:count, record.id)
      cookies[cookie_key] = { value: "1", expires: 24.hours.from_now }
    end

    render "check_ins/success"
  end
end
