module Events
  module Submission
    class Created < ::Event
      def submission_assets
        data[:submission_assets]
      end

      def file_count
        submission_assets.map {|_type, changes| changes.count}.sum
      end

      def path
        data[:path]
      end
    end
  end
end
