class GradingScalePolicy < PunditBasePolicy
  def edit?
    update?
  end

  def update?
    user.admin? || user.lecturer_of_term?(record.term)
  end
end
