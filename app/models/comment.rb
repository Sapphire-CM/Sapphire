# create_table :comments, force: :cascade do |t|
#   t.integer  :commentable_id,   null: false
#   t.string   :commentable_type, null: false
#   t.integer  :account_id,       null: false
#   t.integer  :term_id,          null: false
#   t.string   :name,             null: false
#   t.text     :content,          null: false
#   t.datetime :created_at,       null: false
#   t.datetime :updated_at,       null: false
# end
#
# add_index :comments, [:account_id], name: :index_comments_on_account_id
# add_index :comments, [:commentable_type, :commentable_id], name: :index_comments_on_commentable_type_and_commentable_id

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :account
  belongs_to :term

  validates :account, presence: true
  validates :term, presence: true
  validates :content, presence: true

  def commentable_index
    if commentable.is_a?(SubmissionEvaluation)
      {klass: commentable, id: commentable.id}
    elsif commentable.is_a?(Evaluation)
      {klass: commentable.submission_evaluation, id: commentable.submission_evaluation.id}
    end
  end
end
