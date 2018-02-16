FactoryGirl.define do
  factory :submission do
    submitted_at { Time.now }
    exercise
    association :submitter, factory: :account
    outdated false

    trait :with_student_group do
      transient do
        student_group_title 'G1-01'
      end

      before(:create) do |instance, evaluator|
        instance.student_group = create(:student_group, title: evaluator.student_group_title)
      end
    end

    trait :with_exercise_registrations do
      transient do
        exercise_registrations_count 3
      end

      after(:create) do |instance, evaluator|
        create_list(:exercise_registration, evaluator.exercise_registrations_count, exercise: instance.exercise, submission: instance)
      end
    end

    trait :evaluated do
      transient do
        evaluator { FactoryGirl.create(:account, :admin) }
      end

      after(:create) do |instance, evaluator|
        instance.submission_evaluation.update(evaluator: evaluator.evaluator, evaluated_at: Time.now)
      end
    end

    trait :without_submission_evaluation do
      after(:create) do |instance, evaluator|
        instance.submission_evaluation.destroy
      end
    end

    trait :spreaded_submission_time do
      transient do
        start_time { Time.now }
        time_increment { -5.minutes }
      end

      sequence(:submitted_at) { |n| start_time + time_increment * n}
    end

    trait :outdated do
      outdated true
    end

    trait :with_basic_structure do
      transient do
        files %w(file1.txt nested/file2.txt nested/file3.txt nested/further/file4.txt very/deeply/nested/folder/file5.txt)
      end

      after(:create) do |instance, evaluator|
        evaluator.files.each do |file|
          path, filename = File.split(file)

          path = "" if path == "."

          create(:submission_asset, submission: instance, path: path, file: prepare_static_test_file('simple_submission.txt', open: true, rename_to: filename))
        end
      end
    end
  end
end
