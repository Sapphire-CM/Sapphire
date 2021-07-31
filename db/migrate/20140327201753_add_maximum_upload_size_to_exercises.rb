class AddMaximumUploadSizeToExercises < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :maximum_upload_size, :integer
  end
end
