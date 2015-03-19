class StudentGroupPolicy < PunditBasePolicy
  def index?
    authorized?(record)
  end

  def show?
    user.admin? || user.staff_of_term?(record.term)
  end

  def new?
    create?
  end

  def create?
    authorized?
  end

  def edit?
    update?
  end

  def update?
    authorized?
  end

  def destroy?
    authorized?
  end

  def search_students?
    authorized?(record)
  end

  private

  def authorized?(r = nil)
    user.admin? || user.lecturer_of_term?(r || record.term)
  end
end
