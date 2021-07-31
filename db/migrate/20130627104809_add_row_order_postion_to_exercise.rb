class AddRowOrderPostionToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :row_order, :integer
  end
end
