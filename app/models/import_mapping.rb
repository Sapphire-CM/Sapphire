class ImportMapping < ActiveRecord::Base
  belongs_to :import

  validates :import, presence: true

  IMPORTABLE = %i(group email forename surname matriculation_number comment)

  def swapped
    IMPORTABLE.map {|a| [send(a), a] }.to_h
  end
end
