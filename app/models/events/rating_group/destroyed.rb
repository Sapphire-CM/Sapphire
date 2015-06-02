module Events
  module RatingGroup
    class Destroyed < ::Event
      data_reader :exercise_title, :exercise_id, :rating_group_title, :rating_group_id, :points
    end
  end
end
