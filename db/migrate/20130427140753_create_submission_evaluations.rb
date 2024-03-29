class CreateSubmissionEvaluations < ActiveRecord::Migration[4.2]
  def change
    create_table :submission_evaluations do |t|
      t.belongs_to :submission
      t.belongs_to :evaluator
      t.string :evaluator_type
      t.datetime :evaluated_at

      t.timestamps null: false
    end
    add_index :submission_evaluations, :submission_id
    add_index :submission_evaluations, :evaluator_id
  end
end
