class SubmissionPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    user.tutor_of_tutorial_group?(record.tutorial_group)
  end

  def show?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term) ||
    user.tutor_of_tutorial_group?(record.student_group_registration.student_group.tutorial_group)
  end
end
