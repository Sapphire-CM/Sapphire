module Events
  module Submission
    class Updated < ::Event
      data_reader :submission_assets, :exercise_title, :exercise_id, :path, :submission_id

      def only_additions?
        submission_assets[:added].any? && submission_assets[:updated].empty? && submission_assets[:destroyed].empty?
      end

      def only_updates?
        submission_assets[:added].empty? && submission_assets[:updated].any? && submission_assets[:destroyed].empty?
      end

      def only_removals?
        submission_assets[:added].empty? && submission_assets[:updated].empty? && submission_assets[:destroyed].any?
      end

      def additions
        submission_assets[:added]
      end

      def updates
        submission_assets[:updated]
      end

      def removals
        submission_assets[:destroyed]
      end
    end
  end
end
