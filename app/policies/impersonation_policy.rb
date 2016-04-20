class ImpersonationPolicy < PunditBasePolicy
  def create?
    user.admin?
  end

  def destroy?
    true
  end
end
