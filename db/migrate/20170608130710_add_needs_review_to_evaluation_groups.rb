class AddNeedsReviewToEvaluationGroups < ActiveRecord::Migration
  def change
    add_column :evaluation_groups, :needs_review, :boolean, default: false
  end
end
