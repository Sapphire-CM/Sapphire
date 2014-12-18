module GradingReviewsHelper
  def grading_review_evaluations(submission)
    groups_to_show = []
    submission.submission_evaluation.evaluation_groups.includes([:rating_group, evaluations: :rating]).each do |evaluation_group|
      evaluations_to_show = []

      evaluation_group.evaluations.each do |evaluation|
        evaluations_to_show << evaluation if (evaluation.is_a?(BinaryEvaluation) && evaluation.value == 1) || (!evaluation.is_a?(BinaryEvaluation) && evaluation.value.present?)
      end

      groups_to_show << {group: evaluation_group, evaluations: evaluations_to_show} if evaluations_to_show.any?
    end

    render "grading_review/evaluations_list", groups: groups_to_show.sort_by{|g| g[:group].rating_group.row_order}
  end
end
