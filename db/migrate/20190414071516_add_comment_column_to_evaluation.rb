class AddCommentColumnToEvaluation < ActiveRecord::Migration
  def change
  	add_column :evaluations, :comment, :text
  end
end
