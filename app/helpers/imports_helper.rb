module ImportsHelper
  def import_progress_bar_status(import)
    unless import.running?
      if import.import_result.success?
        "success"
      else
        "alert"
      end
    end
  end
end
