# create_table :comments, force: :cascade do |t|
#   t.string   :commentable_type,                 null: false
#   t.integer  :commentable_id,                   null: false
#   t.integer  :account_id,                       null: false
#   t.integer  :term_id,                          null: false
#   t.string   :name,                             null: false
#   t.boolean  :markdown,         default: false, null: false
#   t.text     :content,                          null: false
#   t.datetime :created_at,                       null: false
#   t.datetime :updated_at,                       null: false
#   t.index [:account_id], name: :index_comments_on_account_id
#   t.index [:commentable_type, :commentable_id], name: :index_comments_on_commentable_type_and_commentable_id
# end

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :account
  belongs_to :term

  validates :account, presence: true
  validates :term, presence: true
  validates :content, presence: true
end
