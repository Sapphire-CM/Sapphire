# create_table :submission_asset_renames, force: :cascade do |t|
#   t.integer  :submission_asset_id
#   t.datetime :renamed_at
#   t.string   :filename_old
#   t.string   :filename_new
#   t.integer  :renamed_by_id,       limit: 8
# end

class SubmissionAssetRename
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :submission_asset, :submission, :new_filename, :renamed_at, :filename_old, :renamed_by

  validates :submission_asset, :submission, :new_filename, :renamed_at, :filename_old, :renamed_by, presence: true
  validate :new_filename_unique

  delegate :id, :submission, to: :submission_asset
  delegate :term, to: :submission

  def save!
    set_default_new_filename
    return false unless valid?
    submission_asset.update_attribute(:filename, new_filename)
  end

  def new_filename_unique
    errors.add(:new_filename, :taken) if new_filename_is_taken_by_existing_asset? || new_filename_is_taken_by_existing_folder?
  end

  def new_filename_is_taken_by_existing_asset?
    SubmissionAsset.exists?(submission: submission,
                             filename: new_filename,
                             path: @submission_asset.path)
  end

  def new_filename_is_taken_by_existing_folder?
    directory = submission.tree.resolve(@submission_asset.path)
    directory[new_filename].present?
  end

  def set_default_new_filename
     self.new_filename ||= submission_asset.filename
   end
end
