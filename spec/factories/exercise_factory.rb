FactoryGirl.define do
  sequence(:exercise_title) { |n| "Exercise #{n}" }

  factory :exercise do
    title { generate :exercise_title }
    description { generate :lorem_ipsum }
    deadline { Time.now + 14.days }
    late_deadline { deadline || Time.now + 2.days }
    enable_max_total_points false
    enable_student_uploads true
    max_total_points 0
    group_submission false

    term

    trait :with_viewer do
      submission_viewer_identifier do
        Sapphire::SubmissionViewers::Central.registered_viewers.first.identifier
      end
    end

    trait :with_upload_limit do
      maximum_upload_size 1024**1 * 5
    end

    trait :group_exercise do
      group_submission true
    end

    trait :no_upload_allowed do
      enable_student_uploads false
    end

    trait :with_ratings do
      after :create do |exercise|
        FactoryGirl.create_list :rating_group, 4, :with_ratings, exercise: exercise
      end
    end
  end
end
