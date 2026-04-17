class Auth::Host::MagicLinksController < ApplicationController
  def new
  end

  def sent
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.is_host? && user.host_profile&.active?
      token = SecureRandom.urlsafe_base64(32)
      user.host_profile.update!(
        invitation_token: token,
        invitation_token_expires_at: 30.minutes.from_now
      )
      HostMailer.magic_link_email(user.host_profile).deliver_later
    end

    # Always show success to avoid email enumeration
    redirect_to host_magic_link_sent_path
  end
end
