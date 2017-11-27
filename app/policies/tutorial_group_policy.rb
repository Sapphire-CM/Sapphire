class TutorialGroupPolicy < TermBasedPolicy
  def index?
    staff_permissions?
  end

  def show?
    staff_permissions?
  end

  def create?
    lecturer_permissions?
  end

  def update?
    lecturer_permissions?
  end

  def destroy?
    lecturer_permissions?
  end

  def points_overview?
    show?
  end
end
