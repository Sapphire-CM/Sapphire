class ServicePolicy < PunditBasePolicy
  def index?
    authorized?
  end

  def edit?
    update?
  end

  def update?
    authorized?
  end

  private

  def authorized?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

end
