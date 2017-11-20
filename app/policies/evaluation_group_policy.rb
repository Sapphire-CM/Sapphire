class EvaluationGroupPolicy < ApplicationPolicy
  def update?
    user.admin? ||
    user.staff_of_term?(record.submission_evaluation.submission.term)
  end
end
