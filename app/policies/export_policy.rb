class ExportPolicy < PunditBasePolicy
  def index?
    authorized?
  end

  def show?
    authorized?
  end

  def new?
    authorized?
  end

  def create?
    authorized?
  end

  def download?
    show?
  end

  def destroy?
    authorized?
  end

  private
  def authorized?
    user.admin? || user.lecturer_of_term?(record.term)
  end
end