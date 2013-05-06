class AddEvaluationResultToSubmissionEvaluations < ActiveRecord::Migration
  def change
    add_column :submission_evaluations, :evaluation_result, :integer
  end
end
