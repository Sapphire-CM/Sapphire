class GradingScalePolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record)
  end

  def update?
    user.admin? ||
    user.lecturer_of_term?(record)
  end
end
