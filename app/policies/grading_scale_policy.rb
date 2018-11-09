class GradingScalePolicy < TermBasedPolicy
  def index?
    lecturer_permissions?
  end

  def update?
    lecturer_permissions?
  end

  def bulk_update?
    update?
  end
end
