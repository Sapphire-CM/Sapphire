class Import < ActiveRecord::Base
  belongs_to :term

  mount_uploader :file, ImportsUploader

  has_one :import_options, inverse_of: :import, dependent: :destroy
  has_one :import_mapping, inverse_of: :import, dependent: :destroy
  has_one :import_result, inverse_of: :import, dependent: :destroy

  enum status: [:pending, :running, :finished, :failed]

  validates :term, presence: true
  validates :file, presence: true

  after_create :create_associations

  accepts_nested_attributes_for :import_options, update_only: true
  accepts_nested_attributes_for :import_mapping, update_only: true

  after_initialize do
    self.status ||= :pending

    if persisted?
      self.import_options ||= ImportOptions.find_or_create_by! import: self
    end
  end

  private

  def create_associations
    # must exist at all times
    ImportMapping.create! import: self
    ImportResult.create! import: self
  end
end
