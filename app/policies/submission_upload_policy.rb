class SubmissionUploadPolicy < TermBasedPolicy
  def create?
    staff_permissions? ||
    (
      record.students.include?(user) &&
      record.submission.modifiable_by_students?
    )
  end
end
