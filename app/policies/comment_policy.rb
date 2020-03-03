class CommentPolicy < TermBasedPolicy
  def index?
    staff_permissions? || student?
  end

  def show?
    create?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def create?
    staff_permissions?
  end
end
