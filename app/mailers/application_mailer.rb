class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Signal Fire <noreply@signalfire.app>")
  layout "mailer"
end
