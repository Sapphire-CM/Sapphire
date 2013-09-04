class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group

  has_one :term, through: :tutorial_group
  has_many :student_registrations, dependent: :destroy
  has_many :students, through: :student_registrations

  has_many :student_group_registrations
  has_many :exercises, through: :student_group_registrations
  has_many :submissions, through: :student_group_registrations

  attr_accessible :title, :solitary

  def register_for(exercise)
    raise ArgumentError, "Exercise is not in same term" unless self.term == exercise.term

    self.student_group_registrations.where(:exercise_id => exercise.id).first_or_create!
  end
end
