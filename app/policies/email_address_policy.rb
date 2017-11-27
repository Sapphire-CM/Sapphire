class EmailAddressPolicy < ApplicationPolicy
  def index?
    user.admin? ||
    user == record.account
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
