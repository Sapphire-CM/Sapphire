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

class Ratings::ValueRating < Rating
  validates :min_value, presence: true
  validates :max_value, presence: true
  validate :all_values_range

  def evaluation_class
    Evaluations::ValueEvaluation
  end

  def all_values_range
    if max_value && min_value && max_value < min_value
      errors.add :min_value, 'maximum value must be greater than minimum value'
    end
  end

  def initialize(*args)
    fail 'Cannot directly instantiate a ValueRating' if self.class == ValueRating
    super
  end
end
