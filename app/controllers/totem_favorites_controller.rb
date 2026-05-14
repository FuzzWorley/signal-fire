class TotemFavoritesController < ApplicationController
  before_action :require_user!

  def create
    favorite = current_user.totem_favorites.find_or_create_by!(
      totem_id: params[:totem_id]
    )
    render json: { id: favorite.id }
  end

  def destroy
    current_user.totem_favorites.find(params[:id]).destroy
    head :no_content
  end
end
