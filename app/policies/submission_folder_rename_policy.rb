class SubmissionFolderRenamePolicy < TermBasedPolicy
  def new?
    authorized?
  end

  def create?
    authorized?
  end

  private
  def authorized?
    staff_permissions? ||
      (
        record.students.include?(user) &&
          record.submission.modifiable_by_students?
      )
  end
end

