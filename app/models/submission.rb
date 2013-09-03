class Submission < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :student_group_registration
  has_one :student_group, through: :student_group_registration

  has_one :submission_evaluation

  attr_accessible :submitted_at

  validates_presence_of :submitted_at, :exercise
  validates_uniqueness_of :exercise_id, scope: :student_group_registration_id


  scope :for_term, lambda {|term| joins(:exercise).where(exercise: {term_id: term.id})}

  def evaluated?
    submission_evaluation.present?
  end
end
