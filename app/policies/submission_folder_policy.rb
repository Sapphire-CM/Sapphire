class SubmissionFolderPolicy < PunditBasePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record.submission.term) ||
    (
      record.submission.students.include?(user) &&
      record.submission.modifiable_by_students?
    )
  end

  def new?
    create?
  end

  def create?
    user.admin? ||
    user.staff_of_term?(record.submission.term) ||
    (
      record.submission.students.include?(user) &&
      record.submission.modifiable_by_students?
    )
  end
end
