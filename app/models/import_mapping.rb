class ImportMapping < ActiveRecord::Base
  belongs_to :import

  validates :import, presence: true
  validates :import_id, uniqueness: true

  IMPORTABLE = %i(group email forename surname matriculation_number comment).freeze
end
