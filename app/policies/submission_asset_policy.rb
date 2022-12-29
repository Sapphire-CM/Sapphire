class SubmissionAssetPolicy < TermBasedPolicy
  def show?
    staff_permissions?(record.submission.exercise.term) ||
    record.submission.visible_for_student?(user)
  end

  def rename?
    staff_permissions?(record.submission.exercise.term) ||
      modifiable?
  end

  def update?
    staff_permissions?(record.submission.exercise.term) ||
      modifiable?
  end

  def destroy?
    staff_permissions?(record.submission.exercise.term) ||
    modifiable?
  end

  private
  def modifiable?
    submission = record.submission

    submission.visible_for_student?(user) &&
    submission.modifiable_by_students? &&
    record.exercise.term.course.unlocked?
  end
end
