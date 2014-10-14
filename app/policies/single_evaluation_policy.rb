class SingleEvaluationPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_of_term?(record.submission.exercise.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_of_term?(record.submission.exercise.term)
  end
end
