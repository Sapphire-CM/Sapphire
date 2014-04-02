class ExercisePolicy < PunditBasePolicy
  def index?
    user.admin? || record.associated_with?(user)
  end

  def show?
    user.admin? || record.term.associated_with?(user)
  end

  def new?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def tutorial_group_dropdown?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end
end
