class TutorialGroupPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record.subject)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record.term)
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

  def points_overview?
    user.admin? ||
    user.staff_of_term?(record.term)
  end
end
