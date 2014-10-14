class AddEnableMaxUploadSizeToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :enable_max_upload_size, :boolean
  end
end
