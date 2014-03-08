class CoursePolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_registrations.count > 0 ||
    user.tutor_registrations.count > 0
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
end
