# do not create this factory
# it will create circular dependencies

FactoryGirl.define do
  factory :evaluation_group do
    rating_group
    submission_evaluation
  end

end
