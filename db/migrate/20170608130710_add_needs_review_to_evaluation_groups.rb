class AddNeedsReviewToEvaluationGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluation_groups, :needs_review, :boolean, default: false
  end
end
