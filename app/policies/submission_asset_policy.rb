class SubmissionAssetPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_of_tutorial_group?(record.submission.student_group_registration.student_group.tutorial_group)
  end

  def new?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_of_tutorial_group?(record.submission.student_group_registration.student_group.tutorial_group)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.submission.exercise.term) ||
    user.tutor_of_tutorial_group?(record.submission.student_group_registration.student_group.tutorial_group)
  end
end
