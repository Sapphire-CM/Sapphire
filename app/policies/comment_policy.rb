class CommentPolicy < TermBasedPolicy
  def show?
    modify?
  end

  def edit?
    modify?
  end

  def update?
    modify?
  end

  def destroy?
    modify?
  end

  def create?
    modify?
  end

  private
  def modify?
    staff_permissions?
  end
end
