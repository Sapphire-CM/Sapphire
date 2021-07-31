require 'rails_helper'

RSpec.describe SubmissionUpload do
  it { is_expected.to be_a(ActiveModel::Model) }

  describe "attr_accessor" do
    describe ':submission' do
      let(:submission) { FactoryBot.build(:submission) }

      it 'assigns and returns submission' do
        subject.submission = submission

        expect(subject.submission).to eq(submission)
      end
    end

    describe 'submitter' do
      let(:account) { FactoryBot.build(:account) }

      it 'assigns and returns submitter' do
        subject.submitter = account

        expect(subject.submitter).to eq(account)
      end
    end

    describe 'path' do
      it 'assigns and returns path' do
        subject.path = "test/path"

        expect(subject.path).to eq("test/path")
      end
    end

    describe 'file' do
      let(:file) { prepare_static_test_file("simple_submission.txt") }

      it 'assigns and returns file' do
        subject.file = file

        expect(subject.file).to eq(file)
      end
    end

    describe 'submission_asset' do
      let(:submission_asset) { FactoryBot.build(:submission_asset) }

      it 'assigns and returns submission_asset' do
        subject.submission_asset = submission_asset

        expect(subject.submission_asset).to eq(submission_asset)
      end

      it 'assigns a new submission_asset if it is not present' do
        subject.submission_asset = nil

        expect(subject.submission_asset).to be_a(SubmissionAsset)
      end
    end
  end

  describe 'delegation' do
    context 'to submission' do
      let(:submission) { double }
      subject { described_class.new(submission: submission) }

      it 'delegates #term' do
        expect(submission).to receive(:term)

        subject.term
      end

      it 'delegates #exercise' do
        expect(submission).to receive(:exercise)

        subject.exercise
      end

      it 'delegates #students' do
        expect(submission).to receive(:students)

        subject.students
      end
    end

    context 'to submission_asset' do
      let(:submission_asset) { double }

      subject { described_class.new(submission_asset: submission_asset)}

      it 'delegates #errors' do
        expect(submission_asset).to receive(:errors)

        subject.errors
      end

      it 'delegates #valid?' do
        expect(submission_asset).to receive(:valid?)

        subject.valid?
      end
    end
  end

  describe '#save' do
    context 'valid attributes' do
      let(:submission) { FactoryBot.create(:submission) }
      let(:term) { submission.term }
      let(:account) { FactoryBot.create(:account) }
      let(:text_file) { prepare_static_test_file("simple_submission.txt") }
      let(:zip_file) { prepare_static_test_file("submission.zip") }

      subject { described_class.new(submission: submission, submitter: account, file: text_file, path: "test/path") }

      let(:event_service) { double }

      it 'saves the submission asset' do
        expect do
          expect(subject.save).to be_truthy
        end.to change(SubmissionAsset, :count).by(1)
      end

      it 'sets the submitter during save' do
        subject.save

        expect(subject.submission_asset.submitter).to eq(account)
      end

      it 'calls the event service' do
        expect(EventService).to receive(:new).with(account, term).and_return(event_service)
        expect(event_service).to receive(:submission_asset_uploaded!).with(subject.submission_asset)

        expect(subject.save).to be_truthy
      end

      it 'schedules a zip file extraction if upload is a zip file' do
        subject.file = zip_file
        expect(ZipExtractionJob).to receive(:perform_later).with(subject.submission_asset)

        subject.save
      end

      it 'does not schedule a zip file extraction if upload is not an archive' do
        subject.file = text_file
        expect(ZipExtractionJob).not_to receive(:perform_later)

        subject.save
      end
    end

    context 'invalid attribtues' do
      let(:submission) { FactoryBot.create(:submission) }
      let(:term) { submission.term }
      let(:account) { FactoryBot.create(:account) }
      let(:file) { prepare_static_test_file("simple_submission.txt") }

      subject { described_class.new(submission: submission, submitter: account, path: "test/path", file: nil) }

      it 'does not create a new submission asset' do
        expect do
          expect(subject.save).to be_falsey
        end.not_to change(SubmissionAsset, :count)
      end

      it 'does not call the event service' do
        expect_any_instance_of(EventService).not_to receive(:submission_asset_uploaded!)

        expect(subject.save).to be_falsey
      end

      it 'does not schedule a file extraction' do
        expect(ZipExtractionJob).not_to receive(:perform_later).with(subject.submission_asset)

        expect(subject.save).to be_falsey
      end
    end
  end
end
