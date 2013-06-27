class AddRowOrderPostionToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :row_order, :integer, default: 0
  end
end
