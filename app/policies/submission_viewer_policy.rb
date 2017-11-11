class SubmissionViewerPolicy < ApplicationPolicy
  def show?
    user.admin? ||
    user.staff_of_term?(record.submission.exercise.term)
  end
end
