class ImportWorker
  include Sidekiq::Worker

  def perform(import_id)
    import = Import.find(import_id)
    begin
      import.import
    rescue => e
      import.failed!
      import.save!
      raise e
    end
  end
end
