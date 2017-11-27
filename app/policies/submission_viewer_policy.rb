class SubmissionViewerPolicy < TermBasedPolicy
  def show?
    staff_permissions?(record.submission.exercise.term)
  end
end
