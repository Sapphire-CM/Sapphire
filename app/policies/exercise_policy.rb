class ExercisePolicy < TermBasedPolicy
  def index?
    associated?
  end

  def show?
    associated?
  end

  def create?
    modify?
  end

  def update?
    modify?
  end

  def destroy?
    modify?
  end

  private

  def associated?
    admin? ||
    record.term.associated_with?(user)
  end

  def modify?
    lecturer_permissions?
  end
end
