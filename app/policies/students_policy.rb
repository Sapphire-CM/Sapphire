class StudentsPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record)
  end
end
