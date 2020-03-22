class AddFileSizeToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :filesystem_size, :integer, default: 0
  end
end
