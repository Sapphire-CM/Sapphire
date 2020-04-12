FactoryGirl.define do
  factory :feedback_comment, class: Comment do
    account 
    content { generate :lorem_ipsum }
    name "feedback"
    term
    commentable { create(:submission) }
  end

  factory :notes_comment, class: Comment do
    account
    content { generate :lorem_ipsum }
    name "notes"
    term
    commentable { create(:submission) }
  end

  factory :explanations_comment, class: Comment do
    account
    content { generate :lorem_ipsum }
    name "explanations"
    term
    commentable { create(:fixed_evaluation) }
  end
end
