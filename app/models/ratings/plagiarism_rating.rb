# create_table :ratings, force: :cascade do |t|
#   t.integer  :rating_group_id
#   t.string   :title,                        limit: 255
#   t.integer  :value
#   t.datetime :created_at,                               null: false
#   t.datetime :updated_at,                               null: false
#   t.text     :description
#   t.string   :type,                         limit: 255
#   t.integer  :max_value
#   t.integer  :min_value
#   t.integer  :row_order
#   t.float    :multiplication_factor
#   t.string   :automated_checker_identifier, limit: 255
# end
#
# add_index :ratings, [:rating_group_id], name: :index_ratings_on_rating_group_id, using: :btree

class Ratings::PlagiarismRating < Ratings::FixedPercentageDeductionRating

  def value
    -100
  end

  protected

  def evaluation_value_type
    :percentage
  end
end
