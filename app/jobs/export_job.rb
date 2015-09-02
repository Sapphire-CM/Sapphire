class ExportJob < ActiveJob::Base
  queue_as :default

  def perform(export)
    export.perform_export!

    NotificationJob.export_finished_notifications(export)
  end
end
