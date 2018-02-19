class Notification::ResultPublicationJob < ActiveJob::Base
  queue_as :default

  def perform(result_publication)
    tutorial_group = result_publication.tutorial_group
    tutorial_group.student_term_registrations.includes(:account).each do |student_term_registration|
      NotificationMailer.result_publication_notification(student_term_registration, result_publication).deliver_later
    end
  end
end
