# create_table :evaluations, force: :cascade do |t|
#   t.boolean  :checked,               default: false, null: false
#   t.integer  :rating_id
#   t.datetime :created_at,                            null: false
#   t.datetime :updated_at,                            null: false
#   t.string   :type
#   t.integer  :value
#   t.integer  :evaluation_group_id
#   t.boolean  :checked_automatically, default: false, null: false
#   t.boolean  :needs_review,          default: false
#   t.index [:evaluation_group_id], name: :index_evaluations_on_evaluation_group_id
#   t.index [:rating_id], name: :index_evaluations_on_rating_id
# end

class Evaluations::VariableEvaluation < Evaluation
  validate :value_range

  def points
    if value.present? && rating.points_value?
      value * rating.multiplication_factor
    else
      0
    end
  end

  def percent
    if value.present? && rating.percentage_value?
      1 + value.to_f / 100.0
    else
      1
    end
  end

  def value_range
    return unless value.present? && rating.is_a?(Ratings::VariableRating)

    if value < rating.min_value || value > rating.max_value
      errors.add :value, "must be between #{rating.min_value} and #{rating.max_value}"
    end
  end


  def show_to_students?
    value.present?
  end
end
