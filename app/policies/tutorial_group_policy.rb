class TutorialGroupPolicy < TermBasedPolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record.term)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record.term)
  end

  def new?
    create?
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def edit?
    update?
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
