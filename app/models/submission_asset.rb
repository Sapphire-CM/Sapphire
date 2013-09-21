class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission
  mount_uploader :file, SubmissionAssetUploader

  validates_presence_of :file, :submission

  attr_accessible :file, :submission_id

end
