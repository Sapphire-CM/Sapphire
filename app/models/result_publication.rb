class ResultPublication < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :tutorial_group

  validates_presence_of :exercise, :tutorial_group
  validates_uniqueness_of :exercise_id, scope: :tutorial_group_id

  scope :published, lambda { where(published: true) }
  scope :concealed, lambda { where(published: false) }

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
    self.save!
  end
end
