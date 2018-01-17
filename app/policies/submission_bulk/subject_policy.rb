class SubmissionBulk::SubjectPolicy < TermBasedPolicy
  def index?
    record.exercise.enable_bulk_submission_management? && (admin? || staff?(record.exercise.term))
  end
end
