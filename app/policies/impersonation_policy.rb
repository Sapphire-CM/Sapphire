class ImpersonationPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def destroy?
    true
  end
end
