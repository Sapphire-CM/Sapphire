FactoryGirl.define do
  factory :variable_evaluation, class: Evaluations::VariableEvaluation do
    evaluation_group
    rating { variable_points_deduction_rating }
  end

  factory :fixed_evaluation, class: Evaluations::VariableEvaluation do
    evaluation_group
    rating { fixed_points_deduction_rating }
  end

end
