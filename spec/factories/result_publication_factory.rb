# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :result_publication do
    exercise
    tutorial_group
    published false
  end
end
