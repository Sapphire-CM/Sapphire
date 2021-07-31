class AddNeedsReviewToSubmissionEvaluation < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_evaluations, :needs_review, :boolean, default: false
  end
end
