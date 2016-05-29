require "rails_helper"

RSpec.describe SubmissionExtractionService do
  describe 'initialization' do
    let(:submission_asset) { FactoryGirl.build(:submission_asset) }

    it 'requires a submission_asset as parameter' do
      service = nil
      expect do
        service = described_class.new(submission_asset)
      end.not_to raise_error

      expect(service.submission_asset).to eq(submission_asset)
    end

    it 'sets default values' do
      service = described_class.new(submission_asset)

      expect(service.errors).to eq([])
      expect(service.created_assets).to eq([])
    end
  end

  describe '#perform!' do
    let(:submitter) { FactoryGirl.create(:account) }
    let(:zip_asset) { FactoryGirl.build(:submission_asset, :zip, path: "") }
    let(:submission) { zip_asset.submission }

    subject { described_class.new(zip_asset) }

    context 'with valid ZIP archive' do
      it 'extracts zip asset' do
        zip_asset.path = "folder"
        expect do
          subject.perform!
        end.to change(SubmissionAsset, :count).by(2)

        expect(submission.submission_assets(true).map(&:complete_path)).to match_array(%w(folder/simple_submission.txt folder/some_xa__x_xu__x_xo__x_x__x_nasty_file.txt))
      end

      it 'notifies the event service' do
        expect_any_instance_of(EventService).to receive(:submission_asset_extracted!)
        subject.perform!
      end

      it 'removes zip asset, if extraction succeeded' do
        subject.perform!

        expect(SubmissionAsset.exists?(id: zip_asset.id)).to be_falsey
      end

      it 'keeps the submission' do
        subject.perform!

        submission.submission_assets(true).each do |submission_asset|
          expect(submission_asset.submission).to eq(submission)
        end
      end

      it 'keeps the submitted_at timestamp' do
        submission_date = 2.days.ago
        zip_asset.update(submitted_at: submission_date)

        zip_asset.reload

        subject.perform!

        submission.submission_assets(true).each do |submission_asset|
          expect(submission_asset.submitted_at).to eq(zip_asset.submitted_at)
        end
      end

      it 'keeps the zip path of the zip archive' do
        zip_asset.path = "funny/path"

        subject.perform!

        submission.submission_assets(true).each do |submission_asset|
          expect(submission_asset.path).to eq("funny/path")
        end
      end

      it 'does not extract filtered files' do
        zip_asset.file = prepare_static_test_file("submission_nested_archives.zip")

        subject.perform!

        expect(submission.submission_assets(true).map(&:complete_path)).to match_array(%w(import_data.csv import_data_not.csv simple_submission.txt some_folder/submission.zip some_other_folder/some_dir/import_data_invalid_parsing.csv))
      end

      it 'schedules nested zip files for extraction' do
        zip_asset.file = prepare_static_test_file("submission_nested_archives.zip")
        expect(ZipExtractionJob).to receive(:perform_later)

        subject.perform!
      end
    end

    context 'with invalid ZIP archive' do
      it 'does not raise an error if the asset is not a zip archive' do
        zip_asset.file = prepare_static_test_file("simple_submission.txt")
        zip_asset.set_content_type

        expect do
          subject.perform!
        end.not_to raise_error
      end
    end

    context 'with name collisions' do
      let!(:existing_submission_asset) { FactoryGirl.create(:submission_asset, submission: submission, file: prepare_static_test_file("simple_submission.txt"), path: "") }

      it 'sets errors for failed submission assets and updates submission' do
        subject.perform!

        expect(subject.errors.length).to eq(1)
        expect(zip_asset.extraction_status.to_s).to eq("extraction_failed")
      end

      it 'notifies the event service of failed extraction' do
        expect_any_instance_of(EventService).to receive(:submission_asset_extraction_failed!)

        subject.perform!
      end

      it 'does not remove asset if errors occured' do
        subject.perform!

        expect(SubmissionAsset.exists?(id: zip_asset.id)).to be_truthy
      end
    end
  end

  describe '#accumulated_filesize' do
    let(:zip_asset) { FactoryGirl.create(:submission_asset, :zip) }
    let(:plain_text_asset) { FactoryGirl.create(:submission_asset, :plain_text) }

    subject { described_class.new(zip_asset) }

    it 'returns the sum of filesizes after extracting all files' do
      expect(subject.accumulated_filesize).to eq(458)
    end

    it 'returns 0 if the asset is not a zip file' do
      subject = described_class.new(plain_text_asset)

      expect(subject.accumulated_filesize).to eq(0)
    end
  end
end
