class AddFileSizeToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :filesystem_size, :integer, default: 0
  end
end
