class SubmissionUploadPolicy < PunditBasePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    create?
  end

  def create?
    user.admin? ||
    user.staff_of_term?(record.term) ||
    record.students.include?(user)
  end
end
