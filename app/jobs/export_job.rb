class ExportJob < ActiveJob::Base
  queue_as :default

  def perform(export_id)
    export = Export.find(export_id)
    export.perform_export!

    NotificationWorker.export_finished_notifications(export)
  end
end
