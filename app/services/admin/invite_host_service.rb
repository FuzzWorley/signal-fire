class Admin::InviteHostService
  def initialize(name:, email:)
    @name  = name.strip
    @email = email.strip.downcase
  end

  def call
    ActiveRecord::Base.transaction do
      user = User.create!(
        name:        @name,
        email:       @email,
        is_host:     true,
        auth_method: :email
      )

      profile = user.create_host_profile!(
        display_name:                 @name,
        invite_status:                :invited,
        invited_at:                   Time.current,
        invitation_token:             SecureRandom.urlsafe_base64(32),
        invitation_token_expires_at:  7.days.from_now
      )

      HostMailer.invite_email(profile).deliver_later

      user
    end
  end
end
