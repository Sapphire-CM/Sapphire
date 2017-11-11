# create_table :import_errors, force: :cascade do |t|
#   t.integer  :import_result_id
#   t.string   :row,              limit: 255
#   t.string   :entry,            limit: 255
#   t.string   :message,          limit: 255
#   t.datetime :created_at,                   null: false
#   t.datetime :updated_at,                   null: false
# end
#
# add_index :import_errors, [:import_result_id], name: :index_import_errors_on_import_result_id, using: :btree

class ImportError < ActiveRecord::Base
  belongs_to :import_result

  validates :import_result, presence: true
  validates :row, presence: true
  validates :entry, presence: true
  validates :message, presence: true
end
