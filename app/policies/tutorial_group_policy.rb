class TutorialGroupPolicy < PunditBasePolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def new_tutor_registration?
    user.admin?
  end

  def create_tutor_registration?
    user.admin?
  end

  def clear_tutor_registration?
    user.admin?
  end

  def points_overview?
    user.admin?
  end
end
