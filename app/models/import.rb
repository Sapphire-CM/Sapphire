class Import < ActiveRecord::Base
  extend Enum

  belongs_to :term

  mount_uploader :file, ImportsUploader

  has_one :import_options, inverse_of: :import, dependent: :destroy
  has_one :import_mapping, inverse_of: :import, dependent: :destroy
  has_one :import_result, inverse_of: :import, dependent: :destroy

  enum status: [:pending, :running, :finished, :failed]

  validates :term, presence: true
  validates :file, presence: true

  after_create :create_associations

  accepts_nested_attributes_for :import_options
  accepts_nested_attributes_for :import_mapping

  after_initialize do
    self.status ||= :pending
  end

  private

  def create_associations
    ImportOptions.create! import: self
    ImportMapping.create! import: self
    ImportResult.create! import: self
  end
end
