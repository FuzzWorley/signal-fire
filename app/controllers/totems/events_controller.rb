class Totems::EventsController < ApplicationController
  def show
    @totem = Totem.find_by!(slug: params[:slug])
    @event = @totem.events.find_by!(slug: params[:event_slug])
    @window_state = @event.window_state
  end
end
