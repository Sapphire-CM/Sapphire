class StudentResultsPolicy < TermBasedPolicy
  def index?
    student?
  end

  def show?
    record.submission.result_published? &&
    record.submission.exercise_registrations.for_student(user).exists?
  end
end
