class StudentSubmissionPolicy < TermBasedPolicy
  def show?
    user.student_of_term?(record.term)
  end
end
