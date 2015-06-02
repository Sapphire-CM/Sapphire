module Events
  module Rating
    class Destroyed < ::Event
      data_reader :exercise_title, :exercise_id, :rating_title, :rating_group_title, :rating_group_id, :value
    end
  end
end
