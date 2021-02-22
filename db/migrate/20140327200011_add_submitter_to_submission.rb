class AddSubmitterToSubmission < ActiveRecord::Migration
  def change
    add_reference :submissions, :submitter, index: true
  end
end
