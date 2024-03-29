class GradingReview::ReviewableEvaluationGroup
  include ActiveModel::Model

  attr_accessor :evaluation_group, :evaluations

  delegate :rating_group, :rating_group_id, to: :evaluation_group
  delegate :row_order, to: :rating_group

  def evaluations?
    !evaluations.empty?
  end

  def sorted_evaluations
    evaluations.sort_by(&:row_order)
  end
end