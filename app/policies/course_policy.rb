class CoursePolicy < PunditBasePolicy
  def index?
    user.present?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def create_term?
    user.admin? || (
      record &&
      record.terms.any? &&
      user.lecturer_of_any_term_in_course?(record)
    )
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
