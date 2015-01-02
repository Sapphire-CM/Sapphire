class ImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)

    ImportService.new(import).perform!
  end
end
