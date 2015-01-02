class ImportError < ActiveRecord::Base
  belongs_to :import_result

  validates :import_result, presence: true
  validates :row, presence: true
  validates :entry, presence: true
  validates :message, presence: true
end
