class StudentsPolicy < TermBasedPolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record.term)
  end

  def show?
    user.admin? ||
    user.staff_of_term?(record.term)
  end
end
