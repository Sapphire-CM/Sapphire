class AddPlagiarazedToSubmissionEvaluation < ActiveRecord::Migration
  def change
    add_column :submission_evaluations, :plagiarized, :boolean
  end
end
