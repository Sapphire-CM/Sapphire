class RatingPolicy < PunditBasePolicy
  def new?
    user.admin? ||
    user.lecturer_of_term?(record.rating_group.exercise.term)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.rating_group.exercise.term)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record.rating_group.exercise.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.rating_group.exercise.term)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record.rating_group.exercise.term)
  end

  def update_position?
    user.admin? ||
    user.lecturer_of_term?(record.rating_group.exercise.term)
  end
end
