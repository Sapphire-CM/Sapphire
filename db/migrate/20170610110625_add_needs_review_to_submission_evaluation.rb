class AddNeedsReviewToSubmissionEvaluation < ActiveRecord::Migration
  def change
    add_column :submission_evaluations, :needs_review, :boolean, default: false
  end
end
