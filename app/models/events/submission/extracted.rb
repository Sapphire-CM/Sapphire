module Events
  module Submission
    class Extracted < ::Event
      data_reader :exercise_title, :exercise_id, :submission_id, :zip_file, :zip_path, :extracted_submission_assets

      def file_count
        extracted_submission_assets.length
      end
    end
  end
end
