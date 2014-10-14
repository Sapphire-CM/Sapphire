class ExerciseEvaluationsTablePolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.exercise.term) ||
    user.tutor_of_term?(record.exercise.term)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    (user.tutor_of_term?(record.exercise.term) && user == record.student_group.tutorial_group.tutor)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    (user.tutor_of_term?(record.exercise.term) && user == record.student_group.tutorial_group.tutor)
  end
end
