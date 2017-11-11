class SingleEvaluationPolicy < ApplicationPolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.exercise.term)
  end

  def update?
    user.admin? ||
    user.staff_of_term?(record.exercise.term)
  end
end
