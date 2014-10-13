class WelcomeEmailWorker
  include Sidekiq::Worker

  def perform(term_registration_id, welcome_back)
    term_registration = TermRegistration.find(term_registration_id)

    account = term_registration.account
    term = term_registration.term

    if welcome_back
      WelcomeMailer.welcome_back_notification(account, term).deliver
    else
      WelcomeMailer.welcome_notification(account, term).deliver
    end
  end
end