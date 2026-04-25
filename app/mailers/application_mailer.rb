class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Signal Fire <noreply@signalfire.live>")
  layout "mailer"
end
