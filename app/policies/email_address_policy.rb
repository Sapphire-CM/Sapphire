class EmailAddressPolicy < ApplicationPolicy
  def index?
    admin? ||
    user == record.account
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end
end
