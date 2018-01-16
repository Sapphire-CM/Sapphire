class SubmissionBulk::BulkPolicy < TermBasedPolicy
  def create?
    record.exercise.enable_bulk_submission_management? && (admin? || staff?(record.exercise.term))
  end
end
