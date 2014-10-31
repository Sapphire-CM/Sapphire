class StudentResultsPolicy < PunditBasePolicy
  def index?
    user.admin? || user.student_of_term?(record.subject)
  end

  def show?
    user.admin? || (
      record.subject.result_published? &&
      record.subject.exercise_registrations.for_student(user).exists?
    )
  end
end
