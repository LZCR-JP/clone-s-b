class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Swipe & Bite <no-reply@example.com>")
  layout "mailer"
end
