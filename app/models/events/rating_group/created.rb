module Events
  module RatingGroup
    class Created < ::Event
      data_reader :exercise_title, :exercise_id, :rating_group_title, :rating_group_id
    end
  end
end
