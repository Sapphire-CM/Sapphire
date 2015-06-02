module Events
  module Rating
    class Updated < ::Event
      data_reader :exercise_title, :exercise_id, :rating_title, :rating_group_title, :rating_group_id, :value

      def tracked_changes
        data[:changes].with_indifferent_access
      end
    end
  end
end
