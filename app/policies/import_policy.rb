class ImportPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def new?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def create?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def destroy?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def full_mapping_table?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def results?
    user.admin? ||
    user.lecturer_of_term?(record)
  end
end
