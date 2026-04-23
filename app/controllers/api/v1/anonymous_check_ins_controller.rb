class Api::V1::AnonymousCheckInsController < ActionController::API
  def create
    totem = Totem.find_by(slug: params[:totem_slug])
    return render json: { error: "Not found" }, status: :not_found unless totem

    event = totem.events.find_by(slug: params[:event_event_slug] || params[:event_slug])
    return render json: { error: "Not found" }, status: :not_found unless event

    unless event.active_now?
      return render json: { error: "Check-in window is not open" }, status: :unprocessable_entity
    end

    counter = event.anonymous_check_in_count ||
              event.build_anonymous_check_in_count(count: 0)
    counter.save!
    counter.increment!(:count)

    AnalyticsService.track("check_in_anonymous",
      event_id: event.id, totem_id: totem.id)

    render json: { checked_in: true }, status: :created
  end
end
