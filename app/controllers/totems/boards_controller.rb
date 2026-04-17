class Totems::BoardsController < ApplicationController
  def show
    @totem = Totem.find_by!(slug: params[:slug])

    if params[:dismiss_footer]
      cookies[:footer_dismissed] = { value: "1", path: "/" }
      return redirect_to totem_board_path(@totem.slug)
    end

    if @totem.board_empty?
      render :empty
    else
      @active_now = @totem.active_now_events
      @upcoming   = @totem.upcoming_events
      @footer_dismissed = cookies[:footer_dismissed]
    end
  end
end
