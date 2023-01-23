# create_table :import_mappings, force: :cascade do |t|
#   t.integer  :import_id
#   t.integer  :group
#   t.integer  :email
#   t.integer  :forename
#   t.integer  :surname
#   t.integer  :matriculation_number
#   t.integer  :comment
#   t.datetime :created_at,           null: false
#   t.datetime :updated_at,           null: false
#   t.index [:import_id], name: :index_import_mappings_on_import_id, unique: true
# end

class ImportMapping < ActiveRecord::Base
  belongs_to :import

  validates :import, presence: true
  validates :import_id, uniqueness: true

  IMPORTABLE = %i(group email forename surname matriculation_number comment).freeze
end
