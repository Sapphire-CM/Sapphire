require 'csv'

class Import < ActiveRecord::Base
  extend Enum
  include Import::Parser
  include Import::Importer

  belongs_to :term

  mount_uploader :file, ImportsUploader

  has_one :import_options, dependent: :destroy
  has_one :import_mapping, dependent: :destroy
  has_one :import_result, dependent: :destroy

  enum status: [:pending, :running, :finished, :failed]

  validates :term, presence: true
  validates :file, presence: true

  after_create :create_associations

  accepts_nested_attributes_for :import_options
  accepts_nested_attributes_for :import_mapping

  after_initialize do
    @parsed = false
    @encoding_error = false
    @parsing_error = false

    self.status = :pending
  end

  def prepare_run!
    self.pending!
    import_result.reset!
  end

  def encoding_error?
    @encoding_error
  end

  def parsing_error?
    @parsing_error
  end

  def headers
    parse_csv unless @headers
    @headers
  end

  def values
    parse_csv unless @values
    @values
  end

  def column_count
    if headers && headers.length > 0
      headers.length
    elsif values && values.length > 0
      values.first.length
    else
      0
    end
  end

  private

  def create_associations
    ImportOptions.create! import: self
    ImportMapping.create! import: self
    ImportResult.create! import: self
  end
end
