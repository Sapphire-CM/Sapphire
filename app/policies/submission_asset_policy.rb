class SubmissionAssetPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term) ||
    record.submission.visible_for_student?(user)
  end

  def new?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term)
  end

  def create?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term)
  end
end
