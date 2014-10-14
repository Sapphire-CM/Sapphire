class GradingReviewPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record.term) ||
    user.tutor_of_term?(record.term)
  end

  def show?
    user.admin? ||
    user.lecturer_of_term?(record.term) ||
    user.tutor_of_term?(record.term)
  end
end
