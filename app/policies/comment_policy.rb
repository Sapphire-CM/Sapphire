class CommentPolicy < TermBasedPolicy
  def show?
    update?
  end

  def update?
    true
  end

  def create?
    true
  end
end
