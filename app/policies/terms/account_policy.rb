class Terms::AccountPolicy < TermBasedPolicy
  def index?
    lecturer_permissions?
  end
end
