# spec/factories/submission_asset_renames.rb

FactoryBot.define do
  factory :submission_asset_rename, class: SubmissionAssetRename do
    submission_asset
    submission
    new_filename { "new_filename" }
    renamed_at { Time.now }
    filename_old { submission_asset.filename }
    renamed_by { FactoryBot.create(:account) }
  end
end
