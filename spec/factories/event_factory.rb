FactoryGirl.define do
  factory :event do
    account
    term
    subject { create(:term) }

    factory :submission_created_event, class: Events::Submission::Created do
      subject { create(:submission) }
      term { subject.exercise.term }
      data {
        {
          submission_id: subject.id,
          exercise_id: subject.exercise.id,
          exercise_title: subject.exercise.title,
          files: subject.submission_assets.map {|sa| File.join(sa.path, File.basename(sa.file.to_s)) }
        }
      }
    end
  end
end
