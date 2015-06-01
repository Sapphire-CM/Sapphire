module Events
  module ResultPublication
    class Published < ::Event
      data_reader :exercise_id, :exercise_title, :tutorial_group_id, :tutorial_group_title
    end
  end
end
