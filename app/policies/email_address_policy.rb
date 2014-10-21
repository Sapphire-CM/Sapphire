class EmailAddressPolicy < PunditBasePolicy
  def index?
    permitted?
  end

  def new?
    create?
  end

  def create?
    permitted?
  end

  def edit?
    update?
  end

  def update?
    permitted?
  end

  def destroy?
    permitted?
  end

  private
  def permitted?
    user.admin? ||
    user == record.account
  end
end