class UserMailer < ApplicationMailer
  def magic_link_email(user)
    @user = user
    @magic_link = verify_magic_link_url(token: user.magic_link_token)
    mail(to: user.email, subject: "Your Signal Fire sign-in link")
  end
end
