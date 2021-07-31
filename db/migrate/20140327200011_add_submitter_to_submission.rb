class AddSubmitterToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_reference :submissions, :submitter, index: true
  end
end
