module Events
  module Submission
    class Created < ::Event

      def file_count
        data[:files].count
      end

    end
  end
end
