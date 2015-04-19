class ImportOptions < ActiveRecord::Base
  belongs_to :import

  enum matching_groups: [:first_match, :both_matches]

  validates :import, presence: true
  validates :import_id, uniqueness: true

  after_initialize do
    self.matching_groups            ||= :first_match
    self.tutorial_groups_regexp     ||= '\A(?<tutorial>T[\d]+)\z'
    self.student_groups_regexp      ||= '\AG(?<tutorial>[\d]+)-(?<student>[\d]+)\z'
    self.column_separator           ||= ';'
    self.quote_char                 ||= '"'
    self.decimal_separator          ||= ','
    self.thousands_separator        ||= '.'

    # already have default values from database:
    #   headers_on_first_line
    #   send_welcome_notifications
  end
end
