require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |exception, options|
    not Rails.env.production?
  end

  recipients = begin
    Account.admins.pluck(:email)
  rescue
    ['sapphire@iicm.edu']
  end

  # Email notifier sends notifications by email.
  config.add_notifier :email, {
    email_prefix:         '[Sapphire ERROR] ',
    sender_address:       %{"Sapphire Exception Notifier" <sapphire@iicm.edu>},
    exception_recipients: recipients
  }
end
