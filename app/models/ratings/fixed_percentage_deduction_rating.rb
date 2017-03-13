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
# add_index :ratings, [:rating_group_id], name: :index_ratings_on_rating_group_id

class Ratings::FixedPercentageDeductionRating < Ratings::FixedRating
  # if checked, value counts as follows:
  #  70  => total_value * (1 +  (70/100))
  # -30  => total_value * (1 + (-30/100))

  validates :value, numericality: { less_than_or_equal_to: 0 }
end