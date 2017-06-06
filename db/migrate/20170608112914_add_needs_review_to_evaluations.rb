class AddNeedsReviewToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :needs_review, :boolean, default: false
  end
end
