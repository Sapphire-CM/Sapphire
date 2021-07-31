class AddEvaluationResultToSubmissionEvaluations < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_evaluations, :evaluation_result, :integer
  end
end
