class Api::V1::HostSubscriptionsController < Api::V1::ApplicationController
  before_action :set_subscription, only: [:destroy, :update]

  def create
    host_user = User.find_by(id: params[:host_user_id])
    return render json: { error: "Host not found" }, status: :not_found unless host_user&.is_host?

    sub = current_user.host_subscriptions.find_or_initialize_by(host_user: host_user)
    if sub.persisted?
      return render json: subscription_json(sub)
    end

    if sub.save
      AnalyticsService.track("host_subscribed",
        user_id: current_user.id, host_user_id: host_user.id)
      render json: subscription_json(sub), status: :created
    else
      render json: { error: sub.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def update
    if @sub.update(subscription_params)
      render json: subscription_json(@sub)
    else
      render json: { error: @sub.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def destroy
    @sub.destroy
    AnalyticsService.track("host_unsubscribed",
      user_id: current_user.id, host_user_id: @sub.host_user_id)
    head :no_content
  end

  private

  def set_subscription
    @sub = current_user.host_subscriptions.find_by(id: params[:id])
    render json: { error: "Not found" }, status: :not_found unless @sub
  end

  def subscription_params
    params.permit(:notify_new_event, :notify_reminder)
  end

  def subscription_json(sub)
    {
      id: sub.id,
      host_user_id: sub.host_user_id,
      notify_new_event: sub.notify_new_event,
      notify_reminder: sub.notify_reminder
    }
  end
end
