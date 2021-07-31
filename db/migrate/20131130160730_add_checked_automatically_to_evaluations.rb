class AddCheckedAutomaticallyToEvaluations < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluations, :checked_automatically, :boolean
  end
end
