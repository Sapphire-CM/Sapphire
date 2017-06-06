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
# end
#
# add_index :evaluations, [:evaluation_group_id], name: :index_evaluations_on_evaluation_group_id
# add_index :evaluations, [:rating_id], name: :index_evaluations_on_rating_id

class Evaluations::FixedEvaluation < Evaluation
  def checked?
    value == 1
  end

  def points
    if value == 1 && rating.points_value?
      rating.value
    else
      0
    end
  end

  def percent
    if value == 1 && rating.percentage_value?
      1 + rating.value.to_f / 100.0
    else
      1
    end
  end
end
