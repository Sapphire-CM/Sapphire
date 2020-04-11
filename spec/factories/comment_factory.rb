FactoryGirl.define do
  factory :feedback_comment, class: Comment do
    content { generate :lorem_ipsum }
    name "feedback"
    term
  end

  factory :notes_comment, class: Comment do
    content { generate :lorem_ipsum }
    name "notes"
    term
  end

  factory :explanations_comment, class: Comment do
    content { generate :lorem_ipsum }
    name "explanations"
    term
  end
end
