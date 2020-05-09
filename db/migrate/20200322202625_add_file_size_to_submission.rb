class AddFileSizeToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :filesystem_size, :integer
  end
end
