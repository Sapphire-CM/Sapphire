class Notification::WelcomeJob < ActiveJob::Base
  queue_as :default

  def perform(term_registration)
    account = term_registration.account
    term = term_registration.term

    welcome_back = TermRegistration.where(account: account).where.not(term: term).exists?
    if welcome_back
      NotificationMailer.welcome_back_notification(account, term).deliver_later
    else
      NotificationMailer.welcome_notification(account, term).deliver_later
    end

    term_registration.update(welcomed_at: Time.now)
  end
end
