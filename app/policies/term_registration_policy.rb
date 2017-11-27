class TermRegistrationPolicy < TermBasedPolicy
  def create?
    lecturer_permissions?
  end

  def destroy?
    lecturer_permissions?
  end
end
