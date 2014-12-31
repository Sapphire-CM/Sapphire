class CreateSubmissionAssets < ActiveRecord::Migration
  def change
    create_table :submission_assets do |t|
      t.belongs_to :submission, index: true
      t.string :file
      t.string :content_type
      t.datetime :submitted_at

      t.timestamps null: false
    end
  end
end
