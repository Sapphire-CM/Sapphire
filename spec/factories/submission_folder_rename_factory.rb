# spec/factories/submission_folder_renames.rb

FactoryBot.define do
  factory :submission_folder_rename, class: SubmissionFolderRename do
    submission
    renamed_at { Time.now }
    path_new { "new_path" }
    renamed_by { FactoryBot.create(:account) }

    transient do
      directory { nil }
      path_old { nil }
    end

    after(:build) do |submission_folder_rename, evaluator|
      submission_folder_rename.directory = evaluator.directory
      submission_folder_rename.path_old = evaluator.directory.path
    end
  end
end