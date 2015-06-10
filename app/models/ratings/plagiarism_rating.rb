# create_table :ratings, force: :cascade do |t|
#   t.integer  :rating_group_id
#   t.string   :title
#   t.integer  :value
#   t.datetime :created_at,                   null: false
#   t.datetime :updated_at,                   null: false
#   t.text     :description
#   t.string   :type
#   t.integer  :max_value
#   t.integer  :min_value
#   t.integer  :row_order
#   t.float    :multiplication_factor
#   t.string   :automated_checker_identifier
# end
#
# add_index :ratings, [:rating_group_id], name: :index_ratings_on_rating_group_id, using: :btree

class Ratings::PlagiarismRating < Ratings::BinaryPercentRating
  def title
    'plagiarism'
  end

  def value
    -100
  end
end
