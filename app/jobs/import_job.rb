class ImportJob < ActiveJob::Base
  queue_as :default

  def perform(import_id)
    import = Import.find(import_id)
    ImportService.new(import).perform!
  end
end
