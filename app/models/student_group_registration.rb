class StudentGroupRegistration < ActiveRecord::Base
  belongs_to :student_group
  belongs_to :exercise
  has_many :submissions

  attr_accessible :student_group, :exercise, :student_group_id

  # validate do
  #   all_students = StudentGroupRegistration.unscoped.where(exercise_id: self.exercise_id).map(&:student_group).compact.flat_map(&:students).map(&:id)
  #
  #   overlap = all_students & self.student_group.students.pluck(:id)
  #   unless overlap.empty?
  #     errors.add :student_group, "Students #{overlap} already registered for this exercise"
  #   end
  # end

end
