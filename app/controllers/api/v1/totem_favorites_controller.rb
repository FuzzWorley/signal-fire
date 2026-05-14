class Api::V1::TotemFavoritesController < Api::V1::ApplicationController
  before_action :set_favorite, only: [:destroy, :update]

  def create
    totem = Totem.find_by(id: params[:totem_id])
    return render json: { error: "Totem not found" }, status: :not_found unless totem

    favorite = current_user.totem_favorites.find_or_initialize_by(totem: totem)
    if favorite.persisted?
      return render json: favorite_json(favorite)
    end

    if favorite.save
      AnalyticsService.track("totem_favorited",
        user_id: current_user.id, totem_id: totem.id)
      render json: favorite_json(favorite), status: :created
    else
      render json: { error: favorite.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def update
    if @favorite.update(favorite_params)
      render json: favorite_json(@favorite)
    else
      render json: { error: @favorite.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def destroy
    @favorite.destroy
    AnalyticsService.track("totem_unfavorited",
      user_id: current_user.id, totem_id: @favorite.totem_id)
    head :no_content
  end

  private

  def set_favorite
    @favorite = current_user.totem_favorites.find_by(id: params[:id])
    render json: { error: "Not found" }, status: :not_found unless @favorite
  end

  def favorite_params
    params.permit(:notify_new_event, :notify_reminder)
  end

  def favorite_json(favorite)
    {
      id: favorite.id,
      totem_id: favorite.totem_id,
      notify_new_event: favorite.notify_new_event,
      notify_reminder: favorite.notify_reminder
    }
  end
end
