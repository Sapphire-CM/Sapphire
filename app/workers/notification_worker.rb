class NotificationWorker
  include Sidekiq::Worker

  def self.result_publication_notifications(result_publication)
    self.perform_async("result_publication", result_publication.id)
  end

  def perform(type, subject_id)
    case type
    when "result_publication" then result_publication_notifications(subject_id)
    end
  end

  private
  def result_publication_notifications(result_publication_id)
    result_publication = ResultPublication.find(result_publication_id)

    tutorial_group = result_publication.tutorial_group
    tutorial_group.student_term_registrations.includes(:account).each do |student_term_registration|
      NotificationMailer.result_publication_notification(student_term_registration, result_publication).deliver
    end
  end
end
