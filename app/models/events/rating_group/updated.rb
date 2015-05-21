module Events
  module RatingGroup
    class Updated < ::Event
      data_reader :exercise_title, :exercise_id, :rating_group_title, :rating_group_id

      def tracked_changes
        data[:changes].with_indifferent_access
      end
    end
  end
end
