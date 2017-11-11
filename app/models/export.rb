# create_table :exports, force: :cascade do |t|
#   t.string   :type,       limit: 255
#   t.integer  :status
#   t.integer  :term_id
#   t.string   :file,       limit: 255
#   t.text     :properties
#   t.datetime :created_at,             null: false
#   t.datetime :updated_at,             null: false
# end
#
# add_index :exports, [:term_id], name: :index_exports_on_term_id, using: :btree

class Export < ActiveRecord::Base
  include SerializedProperties
  include Polymorphable

  class ExportError < StandardError
  end

  belongs_to :term
  mount_uploader :file, ExportsUploader

  enum status: [:pending, :running, :finished, :failed]
  polymorphic submission: 'Exports::SubmissionExport', excel_spreadsheet: 'Exports::ExcelSpreadsheetExport'

  validates :term, presence: true

  before_create :assign_default_status

  def policy_class
    ExportPolicy
  end

  def perform!
    raise NotImplementedError
  end

  def perform_export!
    self.status = :running
    self.save!

    perform!

    self.status = :finished
    self.save!
  rescue => e
    self.status = :failed
    self.save!
    raise e
  end

  protected

  def create_export_file(filename)
    tmp_file = Tempfile.new(filename, Rails.root.join('tmp'))
    tmp_file.persist
    tmp_file
  end

  private

  def assign_default_status
    self.status = :pending
  end
end
