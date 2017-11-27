class EvaluationGroupPolicy < TermBasedPolicy
  def update?
    staff_permissions?(record.submission_evaluation.submission.term)
  end
end
