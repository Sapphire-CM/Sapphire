class RatingGroupPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term(record.term)
  end

  def new?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term)
  end

  def update_position?
    user.admin? ||
    user.lecturer_of_term?(record.exercise.term)
  end
end
