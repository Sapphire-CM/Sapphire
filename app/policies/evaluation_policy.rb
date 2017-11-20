class EvaluationPolicy < ApplicationPolicy
  def update?
    user.admin? ||
    user.staff_of_term?(record.evaluation_group.submission_evaluation.submission.term)
  end
end
