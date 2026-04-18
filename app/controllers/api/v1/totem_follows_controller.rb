class Api::V1::TotemFollowsController < Api::V1::ApplicationController
  before_action :set_follow, only: [:destroy, :update]

  def create
    totem = Totem.find_by(id: params[:totem_id])
    return render json: { error: "Totem not found" }, status: :not_found unless totem

    follow = current_user.totem_follows.find_or_initialize_by(totem: totem)
    if follow.persisted?
      return render json: follow_json(follow)
    end

    if follow.save
      AnalyticsService.track("totem_followed",
        user_id: current_user.id, totem_id: totem.id)
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
    AnalyticsService.track("totem_unfollowed",
      user_id: current_user.id, totem_id: @follow.totem_id)
    head :no_content
  end

  private

  def set_follow
    @follow = current_user.totem_follows.find_by(id: params[:id])
    render json: { error: "Not found" }, status: :not_found unless @follow
  end

  def follow_params
    params.permit(:notify_new_event, :notify_reminder)
  end

  def follow_json(follow)
    {
      id: follow.id,
      totem_id: follow.totem_id,
      notify_new_event: follow.notify_new_event,
      notify_reminder: follow.notify_reminder
    }
  end
end
