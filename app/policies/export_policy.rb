class ExportPolicy < TermBasedPolicy
  def index?
    authorized? record.term
  end

  def show?
    authorized?
  end

  def create?
    authorized? record.term
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
