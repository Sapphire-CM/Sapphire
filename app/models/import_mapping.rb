class ImportMapping < ActiveRecord::Base
  belongs_to :import

  validates :import, presence: true

  after_initialize do
    self.group                ||= 0
    self.surname              ||= 3
    self.forename             ||= 4
    self.matriculation_number ||= 6
    self.email                ||= 11
    self.comment              ||= 12
  end
end
