# create_table :ratings, force: :cascade do |t|
#   t.integer  :rating_group_id
#   t.string   :title
#   t.integer  :value
#   t.datetime :created_at,                                   null: false
#   t.datetime :updated_at,                                   null: false
#   t.text     :description
#   t.string   :type
#   t.integer  :max_value
#   t.integer  :min_value
#   t.integer  :row_order
#   t.float    :multiplication_factor
#   t.string   :automated_checker_identifier
#   t.boolean  :bulk,                         default: false
# end
#
# add_index :ratings, [:rating_group_id], name: :index_ratings_on_rating_group_id

class Ratings::FixedPointsDeductionRating < Ratings::FixedRating
  # if checked, value counts as follows:
  #  7  => total_value + 7
  # -3  => total_value + (-3)

  validates :value, numericality: { less_than_or_equal_to: 0 }

  protected

  def evaluation_value_type
    :points
  end
end
