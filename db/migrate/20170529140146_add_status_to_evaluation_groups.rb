class AddStatusToEvaluationGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluation_groups, :status, :integer, default: 0, null: false
  end
end
