class ImportPolicy < PunditBasePolicy
  def show?
    authorized?
  end

  def new?
    create?
  end

  def create?
    authorized?
  end

  def edit?
    update?
  end

  def update?
    authorized?
  end

  def destroy?
    authorized?
  end

  def file?
    authorized?
  end

  def full_mapping_table?
    authorized?
  end

  def results?
    authorized?
  end

  private

  def authorized?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end
end
