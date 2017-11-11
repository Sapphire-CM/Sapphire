class TermRegistrationPolicy < ApplicationPolicy
  def new?
    user.admin? || user.lecturer_of_term?(record.term)
  end

  def create?
    user.admin? || user.lecturer_of_term?(record.term)
  end

  def destroy?
    user.admin? || user.lecturer_of_term?(record.term)
  end
end
