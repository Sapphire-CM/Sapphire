class StudentGroupPolicy < PunditBasePolicy
  def index?
    authorized?(record)
  end

  def edit?
    update?
  end

  def update?
    authorized?(record)
  end

  def search_students?
    authorized?(record)
  end

  private
  def authorized?(r = nil)
    user.admin? || user.lecturer_of_term?(r || record.term)
  end
end