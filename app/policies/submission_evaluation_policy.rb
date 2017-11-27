class SubmissionEvaluationPolicy < TermBasedPolicy
  def show?
    update?
  end

  def update?
    staff_permissions?(record.submission.term)
  end
end
