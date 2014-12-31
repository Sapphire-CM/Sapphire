class NotificationWorker
  include Sidekiq::Worker

  def self.result_publication_notifications(result_publication)
    self.perform_async(:result_publication, result_publication.id)
  end

  def self.export_finished_notifications(export)
    self.perform_async(:export_finished, export.id)
  end

  def self.welcome_notification(term_registration, welcome_back)
    self.perform_async(:welcome, term_registration.id, welcome_back)
  end

  def perform(type, *args)
    case type
    when :result_publication
      result_publication_notifications(*args)
    when :export_finished
      export_finished_notifications(*args)
    when :welcome
      welcome_notification(*args)
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

  def export_finished_notifications(export_id)
    export = Export.find(export_id)

    recipients = (Account.admins + Account.lecturers_for_term(export.term)).uniq
    recipients.each do |recipient|
      NotificationMailer.export_finished_notification(recipient, export).deliver
    end
  end

  def welcome_notification(term_registration_id, welcome_back)
    term_registration = TermRegistration.find(term_registration_id)
    account = term_registration.account
    term = term_registration.term

    welcome_back = TermRegistration.where(account: account).where.not(term: term).exists?
    if welcome_back
      NotificationMailer.welcome_back_notification(account, term).deliver
    else
      NotificationMailer.welcome_notification(account, term).deliver
    end
  end
end
