class EvaluationGroupPolicy < PunditBasePolicy
  def update?
    user.admin? ||
    user.staff_of_term?(record.submission_evaluation.submission.term)
  end
end
