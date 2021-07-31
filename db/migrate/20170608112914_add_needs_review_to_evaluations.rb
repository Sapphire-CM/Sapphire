class AddNeedsReviewToEvaluations < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluations, :needs_review, :boolean, default: false
  end
end
