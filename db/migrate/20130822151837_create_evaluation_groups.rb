class CreateEvaluationGroups < ActiveRecord::Migration
  def change
    create_table :evaluation_groups do |t|
      t.integer :points
      t.float :percent
      t.belongs_to :rating_group, index: true
      t.belongs_to :submission_evaluation, index: true

      t.timestamps
    end
  end
end
