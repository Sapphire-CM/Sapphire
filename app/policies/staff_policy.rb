class StaffPolicy < TermBasedPolicy
  def index?
    user.admin? ||
    user.staff_of_term?(record.term)
  end

  def search?
    user.admin? ||
    user.lecturer_of_term?(record.term)
  end
end
