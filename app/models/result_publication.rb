class ResultPublication < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :tutorial_group

  validates_presence_of :exercise, :tutorial_group

  def self.for(exercise: nil, tutorial_group: nil)
    where(exercise_id: exercise.id, tutorial_group_id: tutorial_group.id).first
  end

  def concealed?
    !published?
  end

  def publish!
    self.published = true
    self.save!
  end

  def conceal!
    self.published = false
    self.save
  end
end
