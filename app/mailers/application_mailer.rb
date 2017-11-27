class ApplicationMailer < ActionMailer::Base
  default from: 'sapphire-no-reply@iicm.tugraz.at'

  layout 'mailer'
end
