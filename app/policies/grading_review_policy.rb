class GradingReviewPolicy < PunditBasePolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end
end
