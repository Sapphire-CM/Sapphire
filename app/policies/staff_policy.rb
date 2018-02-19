class StaffPolicy < TermBasedPolicy
  def index?
    staff_permissions?
  end
end
