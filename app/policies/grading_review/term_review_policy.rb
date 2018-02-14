class GradingReview::TermReviewPolicy < TermBasedPolicy
  def index?
    staff_permissions?
  end

  def show?
    staff_permissions?
  end
end
