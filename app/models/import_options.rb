class ImportOptions < ActiveRecord::Base
  extend Enum

  belongs_to :import

  enum matching_groups: [:first_match, :both_matches]

  validates :import, presence: true
  validates :import_id, uniqueness: true

  after_initialize do
    self.matching_groups        ||= :first_match
    self.tutorial_groups_regexp ||= '\AT(?<tutorial>[\d]+)\z'
    self.student_groups_regexp  ||= '\AG(?<tutorial>[\d]+)-(?<student>[\d]+)\z'
    self.headers_on_first_line  ||= true
    self.column_separator       ||= ';'
    self.quote_char             ||= '"'
    self.decimal_separator      ||= ','
    self.thousands_separator    ||= '.'
  end
end
