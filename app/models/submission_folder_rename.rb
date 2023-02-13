class SubmissionFolderRename
  include ActiveModel::Model
  include ActiveModel::Validations

  validates :submission, :directory, :renamed_at, :path_old, :path_new, :renamed_by, presence: true

  attr_accessor :submission, :directory, :renamed_at, :path_old, :path_new, :renamed_by

  delegate :term, :students, :exercise, to: :submission

  validate :validate_directory_is_not_root_folder, :validate_directory_is_created,
           :validate_new_directory_name_is_not_the_same_as_current_name ,
           :validate_new_directory_name_is_not_taken_by_another_directory_on_the_same_level,
           if: :presence_valid?


  def save!
    return false unless valid?
    submission_assets = @submission.submission_assets.where(path: path_old).
      or(@submission.submission_assets.where("path like ?", "#{path_old}/%"))

    submission_assets.each do |asset|
      new_path = asset.path.sub(File.basename(path_old), path_new)
      asset.path = new_path
    end

    success = submission_assets.all? do |asset|
      asset.valid? && asset.save
    end

    if success
      true
    end
  end

  private

  def presence_valid?
    errors[:submission].blank? &&
      errors[:directory].blank? &&
      errors[:renamed_at].blank? &&
      errors[:path_old].blank? &&
      errors[:path_new].blank? &&
      errors[:renamed_by].blank?
  end

  def validate_directory_is_not_root_folder
    errors.add(:directory, "is the root directory and cannot be renamed") unless ! root_folder?
  end
  def validate_directory_is_created
    errors.add(:directory, "has no nodes and thus not created and cannot be renamed") unless ! directory_not_created?
  end
  def validate_new_directory_name_is_not_the_same_as_current_name
    errors.add(:path_new, "has the same value as the previous name of the directory") unless ! renaming_folder_with_same_name?
  end
  def validate_new_directory_name_is_not_taken_by_another_directory_on_the_same_level
    errors.add(:path_new, "is already taken") unless ! new_folder_name_taken?
  end

  def root_folder?
    directory.parent == nil
  end

  def directory_not_created?
    !directory_created?
  end

  def directory_created?
    directory.entries.present?
  end

  def renaming_folder_with_same_name?
    directory.name == path_new
  end

  def new_folder_name_taken?
    directory.parent.entries.any? { |entry|  entry.name == path_new }
  end

end
