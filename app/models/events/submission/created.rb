module Events
  module Submission
    class Created < ::Event
      data_reader :submission_assets, :exercise_title, :exercise_id, :path, :submission_id

      def file_count
        submission_assets.map { |_type, changes| changes.count }.sum
      end
    end
  end
end
