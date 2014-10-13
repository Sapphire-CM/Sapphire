# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :export do
    type ""
    status 1
    term nil
    file "MyString"
  end
end
