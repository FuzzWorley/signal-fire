class TotemMailer < ApplicationMailer
  def capture_confirmation_email(email_capture)
    @email_capture = email_capture
    @totem = email_capture.totem

    mail(to: email_capture.email, subject: "You're on the list for #{@totem.name}")
  end
end
