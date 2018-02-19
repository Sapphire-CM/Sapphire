class AccountPolicy < ApplicationPolicy
  def index?
    lecturer_permissions?
  end

  def show?
    self? ||
    lecturer_permissions?
  end

  def create?
    lecturer_permissions?
  end

  def update?
    self? ||
    lecturer_permissions?
  end

  def destroy?
    lecturer_permissions? && !self?
  end

  def change_password?
    update?
  end

  def update_password?
    update?
  end

  private
  def lecturer_permissions?
    admin? || lecturer?
  end

  def lecturer?
    user.lecturer_of_any_term?
  end

  def self?
    record == user
  end
end
