FactoryBot.define do
  factory :fixed_evaluation, class: Evaluations::FixedEvaluation do
    evaluation_group
    association :rating, factory: :fixed_points_deduction_rating
  end

  factory :variable_evaluation, class: Evaluations::VariableEvaluation do
    evaluation_group
    association :rating, factory: :variable_points_deduction_rating
  end
end
