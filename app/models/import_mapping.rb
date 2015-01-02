class ImportMapping < ActiveRecord::Base
  belongs_to :import

  validates :import, presence: true
end
