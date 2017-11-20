class SubmissionEvaluationPolicy < ApplicationPolicy
  def show?
    update?
  end

  def update?
    user.admin? ||
    user.staff_of_term?(record.submission.term)
  end
end
