class Api::V1::CheckInsController < Api::V1::ApplicationController
  def create
    event = Event.find_by(id: params[:event_id])
    return render json: { error: "Not found" }, status: :not_found unless event

    unless event.active_now?
      return render json: { error: "Check-in window is not open" }, status: :unprocessable_entity
    end

    check_in = current_user.check_ins.find_by(event: event)
    if check_in
      return render json: { checked_in: true, checked_in_at: check_in.checked_in_at.iso8601 }
    end

    check_in = current_user.check_ins.build(event: event)
    if check_in.save
      AnalyticsService.track("check_in_authenticated",
        user_id: current_user.id, event_id: event.id, totem_id: event.totem_id)
      render json: { checked_in: true, checked_in_at: check_in.checked_in_at.iso8601 },
             status: :created
    else
      render json: { error: check_in.errors.full_messages.first }, status: :unprocessable_entity
    end
  end
end
