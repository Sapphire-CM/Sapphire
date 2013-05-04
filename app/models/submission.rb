class Submission < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :student_registration
  has_one :student, through: :student_registration
  
  has_one :submission_evaluation
  
  attr_accessible :submitted_at
  
  validates_presence_of :submitted_at
  validates_uniqueness_of :exercise_id, scope: :student_registration_id
  
  
  scope :for_term, lambda {|term| joins(:exercise).where(exercise: {term_id: term.id})}
end
