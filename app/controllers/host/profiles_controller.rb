class Host::ProfilesController < Host::ApplicationController
  def edit
    @host_profile = current_user.host_profile
  end

  def update
    @host_profile = current_user.host_profile

    if @host_profile.update(profile_params)
      redirect_to host_profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:display_name, :blurb)
  end
end
