class AccountPolicy < PunditBasePolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def edit?
    user.admin? ||
    user == record
  end

  def update?
    user.admin? ||
    user == record
  end

  def destroy?
    user.admin?
  end

  def change_password?
    user.admin? ||
    user == record
  end

  def update_password?
    user.admin? ||
    user == record
  end
end
