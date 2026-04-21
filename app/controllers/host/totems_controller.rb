class Host::TotemsController < Host::ApplicationController
  def index
    @totems = Totem.joins(:host_totem_assignments)
                   .where(host_totem_assignments: { host_user_id: current_user.id })
                   .order(:name)
  end
end
