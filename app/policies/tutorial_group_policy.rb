class TutorialGroupPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record)
  end

  def new?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def points_overview?
    user.admin? ||
    user.staff_of_term?(record)
  end
end
