FactoryGirl.define do
  sequence(:tutorial_group_title) {|n| "Tut group #{n}"}

  factory :tutorial_group do
    title {generate :tutorial_group_title}
    description {generate :lorem_ipsum}
    term
  end
end