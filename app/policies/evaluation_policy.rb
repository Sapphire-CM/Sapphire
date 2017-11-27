class EvaluationPolicy < TermBasedPolicy
  def update?
    staff_permissions?(record.evaluation_group.submission_evaluation.submission.term)
  end
end
