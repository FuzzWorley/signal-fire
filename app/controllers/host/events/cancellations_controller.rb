class Host::Events::CancellationsController < Host::ApplicationController
  def update
    totem_ids = current_user.host_totem_assignments.pluck(:totem_id)
    @event = Event.find_by!(id: params[:id], host_user_id: current_user.id, totem_id: totem_ids)

    unless @event.one_time?
      return redirect_to host_events_path, alert: "Only one-time events can be cancelled."
    end

    @event.update!(status: :cancelled)
    redirect_to host_events_path, notice: "\"#{@event.title}\" has been cancelled."
  end
end
