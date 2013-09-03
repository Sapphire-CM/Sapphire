class MoveEvaluationsFromSubmissionEvaluationsToEvaluationGroups < ActiveRecord::Migration
  def change
    remove_index :evaluations, :submission_evaluation_id
    rename_column :evaluations, :submission_evaluation_id, :evaluation_group_id
    add_index :evaluations, :evaluation_group_id
  end
end