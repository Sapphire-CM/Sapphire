class MoveEvaluationsToSubmissionEvaluations < ActiveRecord::Migration[4.2]
  def change
    remove_index :evaluations, :student_id 
    remove_column :evaluations, :student_id
    
    add_column :evaluations, :submission_evaluation_id, :integer
    add_index :evaluations, :submission_evaluation_id
  end
end