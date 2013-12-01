class AddCheckedAutomaticallyToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :checked_automatically, :boolean
  end
end
