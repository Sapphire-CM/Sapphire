class TermRegistrationPolicy < PunditBasePolicy
  def new?
    create?
  end

  def create?
    user.admin? || user.lecturer_of_term?(record.term)
  end

  def destroy?
    user.admin? || user.lecturer_of_term?(record.term)
  end
end