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

class Ratings::VariablePointsDeductionRating < Ratings::VariableRating
  # value counts as follows:
  #  7  => total_value + 7
  # -3  => total_value + (-3)

  validates :min_value, :max_value, numericality: { less_than_or_equal_to: 0 }

  after_initialize :ensure_multiplication_factor

  protected

  def ensure_multiplication_factor
    self.multiplication_factor ||= 1
  end

  def evaluation_value_type
    :points
  end
end
