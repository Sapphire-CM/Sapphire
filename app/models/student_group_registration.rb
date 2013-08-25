class StudentGroupRegistration < ActiveRecord::Base
  belongs_to :student_group
  belongs_to :exercise

  attr_accessible :student_group, :exercise, :student_group_id

  has_many :submissions

end
