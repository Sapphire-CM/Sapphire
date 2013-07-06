class StudentGroupRegistration < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :student_group
end
