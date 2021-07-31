FactoryBot.define do
  sequence(:exercise_title) { |n| "Exercise #{n}" }

  factory :exercise do
    title { generate :exercise_title }
    description { generate :lorem_ipsum }
    deadline { Time.now + 14.days }
    late_deadline { deadline || Time.now + 2.days }
    enable_max_total_points { false }
    enable_student_uploads { true }
    max_total_points { 0 }
    group_submission { false }

    term

    trait :with_viewer do
      submission_viewer_identifier do
        Sapphire::SubmissionViewers::Central.registered_viewers.first.identifier
      end
    end

    trait :without_viewer do
      submission_viewer_identifier { nil }
    end

    trait :with_upload_limit do
      maximum_upload_size { 1024**1 * 5 }
    end

    trait :group_exercise do
      group_submission { true }
    end

    trait :solitary_exercise do
      group_submission { false }
    end

    trait :no_upload_allowed do
      enable_student_uploads { false }
    end

    trait :with_ratings do
      after :create do |exercise|
        FactoryBot.create_list :rating_group, 4, :with_ratings, exercise: exercise
      end
    end

    trait :with_minimum_points do
      enable_min_required_points { true }
      min_required_points { 5 }
    end

    trait :without_minimum_points do
      enable_min_required_points { false }
      min_required_points { nil }
    end

    trait :bulk_operations do
      enable_bulk_submission_management { true }
    end

    trait :multiple_attempts do
      enable_multiple_attempts { true }

      attempts do |attempts|
        [attempts.association(:exercise_attempt, title: "Attempt 1", date: Time.now), attempts.association(:exercise_attempt, title: "Attempt 2")]
      end
    end

    trait :single_attempt do
      enable_multiple_attempts { false }
    end
  end
end
