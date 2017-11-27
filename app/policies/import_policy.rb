class ImportPolicy < TermBasedPolicy
  def show?
    authorized?
  end

  def create?
    authorized?
  end

  def update?
    authorized?
  end

  def destroy?
    authorized?
  end

  def file?
    show?
  end

  def full_mapping_table?
    show?
  end

  def results?
    show?
  end

  private
  def authorized?
    lecturer_permissions?
  end
end
