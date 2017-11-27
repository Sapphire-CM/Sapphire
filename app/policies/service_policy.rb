class ServicePolicy < TermBasedPolicy
  def index?
    lecturer_permissions?
  end

  def update?
    lecturer_permissions?
  end
end
