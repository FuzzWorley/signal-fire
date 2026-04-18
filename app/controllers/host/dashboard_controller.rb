class Host::DashboardController < Host::ApplicationController
  def show
    totem_ids = current_user.host_totem_assignments.pluck(:totem_id)
    now = Time.current

    @upcoming_events = Event.where(host_user_id: current_user.id, totem_id: totem_ids)
                            .active
                            .where("end_time >= ?", now)
                            .includes(:totem, :anonymous_check_in_count)
                            .order(:start_time)

    @past_events = Event.where(host_user_id: current_user.id, totem_id: totem_ids)
                        .where("end_time < ?", now)
                        .includes(:totem, :anonymous_check_in_count)
                        .order(end_time: :desc)
                        .limit(20)

    @subscriber_count = HostSubscription.where(host_user_id: current_user.id).count
    @totems = Totem.where(id: totem_ids).order(:name)
  end
end
