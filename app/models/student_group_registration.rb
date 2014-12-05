class StudentGroupRegistration < ActiveRecord::Base
  belongs_to :student_group
  belongs_to :exercise

  has_many :submissions

  validates :student_group, presence: true
  validates :exercise, presence: true
end
