class Notification::ExportFinishedJob < ActiveJob::Base
  queue_as :default

  def perform(export)
    recipients = Account.admins | Account.lecturers_for_term(export.term)
    recipients.each do |recipient|
      NotificationMailer.export_finished_notification(recipient, export).deliver_later
    end
  end
end
