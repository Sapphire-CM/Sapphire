class EmailAddressPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user == record
  end

  def new?
    user.admin? ||
    user == record.account
  end

  def create?
    user.admin? ||
    user == record.account
  end

  def edit?
    user.admin? ||
    user == record.account
  end

  def update?
    user.admin? ||
    user == record.account
  end

  def destroy?
    user.admin? ||
    user == record.account
  end
end
