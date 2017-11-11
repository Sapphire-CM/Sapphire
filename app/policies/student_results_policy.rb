class StudentResultsPolicy < TermBasedPolicy
  def index?
    user.admin? ||
    user.student_of_term?(record.term)
  end

  def show?
    user.admin? || (
      record.submission.result_published? &&
      record.submission.exercise_registrations.for_student(user).exists?
    )
  end
end
