# create_table :notes, force: :cascade do |t|
#   t.integer  :notable_id,   null: false
#   t.string   :notable_type, null: false
#   t.integer  :account_id,   null: false
#   t.integer  :term_id,      null: false
#   t.text     :content
#   t.datetime :created_at,   null: false
#   t.datetime :updated_at,   null: false
# end
#
# add_index :notes, [:account_id], name: :index_notes_on_account_id
# add_index :notes, [:notable_type, :notable_id], name: :index_notes_on_notable_type_and_notable_id

class Note < ActiveRecord::Base
  belongs_to :notable, polymorphic: true
  belongs_to :account
  belongs_to :term

  validates :account, :term, presence: true
end
