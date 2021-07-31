class AddEnableMaxUploadSizeToExercises < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :enable_max_upload_size, :boolean
  end
end
