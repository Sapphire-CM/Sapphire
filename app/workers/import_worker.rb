class ImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)
    begin
      import.running!
      import.import!
    rescue => e
      import.failed!
      raise e
    end
  end
end
