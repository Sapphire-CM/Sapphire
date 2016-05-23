class SubmissionAssetPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term) ||
    record.submission.visible_for_student?(user)
  end

  def destroy?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term) ||
    (
      record.submission.visible_for_student?(user) &&
      record.submission.modifiable_by_students?
    )
  end
end
