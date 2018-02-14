module GradingReviewsHelper
  def grading_review_evaluations(submission_review)
     render 'grading_reviews/evaluations_list', reviewable_groups: submission_review.reviewable_groups
  end
end
