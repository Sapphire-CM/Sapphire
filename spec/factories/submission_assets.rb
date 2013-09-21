# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submission_asset do
    submission nil
    file "MyString"
    submitted_at "2013-09-03 11:32:55"
  end
end
