class RatingGroupPolicy < TermBasedPolicy
  def index?
    lecturer_permissions?(record.term)
  end

  def create?
    modify?
  end

  def update?
    modify?
  end

  def destroy?
    modify?
  end

  def update_position?
    update?
  end

  private
  def modify?
    lecturer_permissions?(record.exercise.term)
  end
end
