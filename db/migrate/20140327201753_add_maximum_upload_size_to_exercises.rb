class AddMaximumUploadSizeToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :maximum_upload_size, :integer
  end
end
