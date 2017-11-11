class SubmissionAssetPolicy < ApplicationPolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term) ||
    record.submission.visible_for_student?(user)
  end

  def destroy?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term) ||
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
