class Host::Profiles::PasswordsController < Host::ApplicationController
  def edit
  end

  def update
    unless current_user.authenticate(params[:password][:current_password])
      flash.now[:alert] = "Current password is incorrect."
      return render :edit, status: :unprocessable_entity
    end

    new_password      = params[:password][:new_password]
    new_confirmation  = params[:password][:new_password_confirmation]

    if new_password != new_confirmation
      flash.now[:alert] = "Passwords do not match."
      return render :edit, status: :unprocessable_entity
    end

    if current_user.update(password: new_password, password_confirmation: new_confirmation)
      redirect_to host_profile_path, notice: "Password updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
