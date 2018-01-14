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

class Ratings::FixedRating < Rating
  validates :value, presence: true

  def initialize(*args)
    fail 'Cannot directly instantiate a FixedRating' if self.class == Ratings::FixedRating
    super
  end

  def evaluation_class
    Evaluations::FixedEvaluation
  end
end
