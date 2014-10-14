class SingleEvaluationPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term)
  end

  def update?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term)
  end
end
