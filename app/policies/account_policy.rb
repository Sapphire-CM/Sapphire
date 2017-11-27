class AccountPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? ||
    self?
  end

  def update?
    admin? ||
    self?
  end

  def destroy?
    admin?
  end

  def change_password?
    update?
  end

  def update_password?
    update?
  end

  private
  def self?
    record == user
  end
end
