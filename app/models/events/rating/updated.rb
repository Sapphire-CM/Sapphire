module Events
  module Rating
    class Updated < ::Event
      def rating_title
        data[:rating_group_title]
      end

      def rating_group_title
        data[:rating_group_title]
      end

      def rating_group_id
        data[:rating_group_id]
      end

      def exercise_id
        data[:exercise_id]
      end

      def exercise_title
        data[:exercise_title]
      end

      def rating_title
        data[:rating_title]
      end

      def tracked_changes
        data[:changes].with_indifferent_access
      end
    end
  end
end
