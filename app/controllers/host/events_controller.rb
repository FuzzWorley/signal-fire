class Host::EventsController < Host::ApplicationController
  before_action :set_event, only: [:edit, :update, :destroy]

  def index
    totem_ids = current_user.host_totem_assignments.pluck(:totem_id)
    @events = Event.where(host_user_id: current_user.id, totem_id: totem_ids)
                   .includes(:totem, :anonymous_check_in_count)
                   .order(start_time: :desc)
  end

  def new
    @event = Event.new
    @totems = host_totems
  end

  def create
    @event = Event.new(event_params)
    @event.host_user = current_user

    if @event.save
      redirect_to host_events_path, notice: "Event created."
    else
      @totems = host_totems
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @totems = host_totems
  end

  def update
    if @event.update(event_params)
      redirect_to host_events_path, notice: "Event updated."
    else
      @totems = host_totems
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to host_events_path, notice: "Event deleted."
  end

  private

  def set_event
    totem_ids = current_user.host_totem_assignments.pluck(:totem_id)
    @event = Event.find_by!(id: params[:id], host_user_id: current_user.id, totem_id: totem_ids)
  end

  def host_totems
    Totem.joins(:host_totem_assignments)
         .where(host_totem_assignments: { host_user_id: current_user.id })
         .order(:name)
  end

  def event_params
    params.require(:event).permit(
      :title, :totem_id, :recurrence_type,
      :start_time, :end_time,
      :description, :community_norms,
      :chat_platform, :chat_url
    )
  end
end
