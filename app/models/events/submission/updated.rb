module Events
  module Submission
    class Updated < ::Event
      def exercise_id
        data[:exercise_id]
      end

      def exercise_title
        data[:exercise_title]
      end

      def submission_assets
        data[:submission_assets]
      end

      def path
        data[:path] || ""
      end

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
