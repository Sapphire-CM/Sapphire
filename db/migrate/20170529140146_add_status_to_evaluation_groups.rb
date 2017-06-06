class AddStatusToEvaluationGroups < ActiveRecord::Migration
  def change
    add_column :evaluation_groups, :status, :integer, default: 0, null: false
  end
end
