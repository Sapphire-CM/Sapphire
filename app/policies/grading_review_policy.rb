class GradingReviewPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    user.lecturer_of_term?(record) ||
    user.tutor_of_any_tutorial_group_in_term?(record)
  end

  def show?
    user.admin? ||
    user.lecturer_of_term?(record) ||
    user.tutor_of_any_tutorial_group_in_term?(record)
  end
end
