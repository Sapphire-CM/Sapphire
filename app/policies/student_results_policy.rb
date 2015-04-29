class StudentResultsPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.student_of_term?(record)
  end

  def show?
    user.admin? || (
      record.result_published? &&
      record.exercise_registrations.for_student(user).exists?
    )
  end
end
