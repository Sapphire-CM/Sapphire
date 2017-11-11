class ServicePolicy < TermBasedPolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def edit?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end
end
