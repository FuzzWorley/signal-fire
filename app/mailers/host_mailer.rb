class HostMailer < ApplicationMailer
  def invite_email(host_profile)
    @host_profile = host_profile
    @magic_link = host_accept_invite_url(token: host_profile.invitation_token)

    mail(to: host_profile.user.email, subject: "You're invited to host on Signal Fire")
  end

  def magic_link_email(host_profile)
    @host_profile = host_profile
    @magic_link = host_magic_link_verify_url(token: host_profile.magic_link_token)

    mail(to: host_profile.user.email, subject: "Your Signal Fire login link")
  end
end
