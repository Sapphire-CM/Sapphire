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

class Ratings::VariableRating < Rating
  validates :min_value, presence: true
  validates :max_value, presence: true
  validate :all_values_range

  def evaluation_class
    Evaluations::VariableEvaluation
  end

  def all_values_range
    if max_value && min_value && max_value < min_value
      errors.add :min_value, 'maximum value must be greater than minimum value'
    end
  end

  def initialize(*args)
    fail 'Cannot directly instantiate a VariableRating' if self.class == Ratings::VariableRating
    super
  end
end
