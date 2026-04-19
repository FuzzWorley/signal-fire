class Totems::EventsController < ApplicationController
  def show
    @totem = Totem.find_by!(slug: params[:slug])
    @event = @totem.events.find_by!(slug: params[:event_slug])
    @window_state = @event.window_state
    @host_profile = @event.host_user.host_profile

    AnalyticsService.track(
      "event_detail_viewed",
      event_id: @event.id,
      totem_id: @totem.id,
      auth_state: current_user ? :authenticated : :anonymous,
      source: params[:source] || :direct
    )
  end
end
