class NotePolicy < TermBasedPolicy
  def show?
    create?
  end

  def edit?
    create?
  end

  def destroy?
    create?
  end

  def create?
    staff_permissions?
  end
end
