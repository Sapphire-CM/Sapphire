# create_table :import_options, force: :cascade do |t|
#   t.integer  :import_id
#   t.integer  :matching_groups
#   t.string   :tutorial_groups_regexp
#   t.string   :student_groups_regexp
#   t.boolean  :headers_on_first_line,      default: true, null: false
#   t.string   :column_separator
#   t.string   :quote_char
#   t.string   :decimal_separator
#   t.string   :thousands_separator
#   t.datetime :created_at,                                null: false
#   t.datetime :updated_at,                                null: false
#   t.boolean  :send_welcome_notifications, default: true, null: false
# end
#
# add_index :import_options, [:import_id], name: :index_import_options_on_import_id, unique: true

class ImportOptions < ActiveRecord::Base
  belongs_to :import

  enum matching_groups: [:first_match, :both_matches]

  validates :import, presence: true
  validates :import_id, uniqueness: true

  after_initialize do
    self.matching_groups            ||= :first_match
    self.tutorial_groups_regexp     ||= '\A(?<tutorial>T[\d]+)\z'
    self.student_groups_regexp      ||= '\AG(?<tutorial>[\d]+)-(?<student>[\d]+)i?\z'
    self.column_separator           ||= ';'
    self.quote_char                 ||= '"'
    self.decimal_separator          ||= ','
    self.thousands_separator        ||= '.'

    # already have default values from database:
    #   headers_on_first_line
    #   send_welcome_notifications
  end
end
