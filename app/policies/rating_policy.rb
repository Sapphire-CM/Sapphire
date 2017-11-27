class RatingPolicy < TermBasedPolicy
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
    lecturer_permissions?(record.rating_group.exercise.term)
  end
end
