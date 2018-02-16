class TermRegistrationPolicy < TermBasedPolicy
  def show?
    staff_permissions?
  end

  def create?
    lecturer_permissions?
  end

  def update?
    lecturer_permissions?
  end

  def destroy?
    lecturer_permissions?
  end
end
