class AddPlagiarazedToSubmissionEvaluation < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_evaluations, :plagiarized, :boolean
  end
end
