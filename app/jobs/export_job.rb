class ExportJob < ActiveJob::Base
  queue_as :default

  def perform(export)
    export.perform_export!

    Notification::ExportFinishedJob.perform_later(export)
  end
end
