class Notification::SendPendingWelcomesJob < ActiveJob::Base
  queue_as :default

  def perform(term)
    term.term_registrations.student.waiting_for_welcome.find_each do |term_registration|
      Notification::WelcomeJob.perform_now(term_registration)
    end
  end
end
