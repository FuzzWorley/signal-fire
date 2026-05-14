class Api::V1::HostFollowsController < Api::V1::ApplicationController
  before_action :set_follow, only: [:destroy, :update]

  def create
    host_user = User.find_by(id: params[:host_user_id])
    return render json: { error: "Host not found" }, status: :not_found unless host_user&.is_host?

    follow = current_user.host_follows.find_or_initialize_by(host_user: host_user)
    if follow.persisted?
      return render json: follow_json(follow)
    end

    if follow.save
      AnalyticsService.track("host_followed",
        user_id: current_user.id, host_user_id: host_user.id)
      render json: follow_json(follow), status: :created
    else
      render json: { error: follow.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def update
    if @follow.update(follow_params)
      render json: follow_json(@follow)
    else
      render json: { error: @follow.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def destroy
    @follow.destroy
    AnalyticsService.track("host_unfollowed",
      user_id: current_user.id, host_user_id: @follow.host_user_id)
    head :no_content
  end

  private

  def set_follow
    @follow = current_user.host_follows.find_by(id: params[:id])
    render json: { error: "Not found" }, status: :not_found unless @follow
  end

  def follow_params
    params.permit(:notify_new_event, :notify_reminder)
  end

  def follow_json(follow)
    {
      id: follow.id,
      host_user_id: follow.host_user_id,
      notify_new_event: follow.notify_new_event,
      notify_reminder: follow.notify_reminder
    }
  end
end
