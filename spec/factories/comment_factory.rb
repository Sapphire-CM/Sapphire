FactoryGirl.define do
  factory :comment do
    content { generate :lorem_ipsum }
    term 
  end
end
