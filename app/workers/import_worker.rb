class ImportWorker
  include Sidekiq::Worker

  def perform(student_import_id)
    student_import = Import::StudentImport.find(student_import_id)
    begin
      student_import.import
    rescue => e
      student_import.import_result[:running] = false
      student_import.status = 'failed'
      student_import.save!
      raise e
    end
  end
end