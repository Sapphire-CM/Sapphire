class StudentsPolicy < TermBasedPolicy
  def index?
    staff_permissions?
  end

  def show?
    staff_permissions?
  end
end
