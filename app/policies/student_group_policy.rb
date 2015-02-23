class StudentGroupPolicy < PunditBasePolicy
  def index?
    authorized?(record)
  end

  private
  def authorized?(r = nil)
    user.admin? || user.lecturer_of_term?(r || record.term)
  end
end