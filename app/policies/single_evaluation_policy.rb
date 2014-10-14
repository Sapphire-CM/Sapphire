class SingleEvaluationPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_registrations.where(tutorial_group_id: record.submission.term_registrations.map(&:tutorial_group_id)).exists?
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_registrations.where(tutorial_group_id: record.submission.term_registrations.map(&:tutorial_group_id)).exists?
  end
end
