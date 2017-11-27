class StaffPolicy < TermBasedPolicy
  def index?
    staff_permissions?
  end

  def search?
    lecturer_permissions?
  end
end
