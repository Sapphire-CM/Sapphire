class StaffPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record)
  end

  def search?
    user.admin? ||
    user.lecturer_of_term?(record)
  end
end
