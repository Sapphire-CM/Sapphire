class ImpersonationPolicy < ApplicationPolicy
  def create?
    user.admin? && user != record.impersonatable
  end

  def destroy?
    true
  end
end
