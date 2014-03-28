FactoryGirl.define do
  sequence(:exercise_title) {|n| "Exercise #{n}"}

  factory :exercise do
    title {generate :exercise_title}
    description {generate :lorem_ipsum}
    deadline {Time.now + 14.days}
    late_deadline {deadline || Time.now + 2.days}
    enable_max_total_points false
    max_total_points 0
    group_submission false

    term

    trait :with_viewer do
      submission_viewer_identifier Sapphire::SubmissionViewers::Central.registered_viewers.first.identifier
    end
  end
end
