class ExportPolicy < PunditBasePolicy
  def index?
    authorized? record
  end

  def show?
    authorized?
  end

  def new?
    authorized? record
  end

  def create?
    authorized? record
  end

  def download?
    authorized?
  end

  def destroy?
    authorized?
  end

  private

  def authorized?(r = nil)
    user.admin? || user.lecturer_of_term?(r || record.term)
  end
end
