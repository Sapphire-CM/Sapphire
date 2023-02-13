require 'rails_helper'

RSpec.describe SubmissionAssetRename, type: :model do

  let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
  let(:exercise) { FactoryBot.create(:exercise, term: term) }
  let(:term) { term_registration.term }
  let(:term_registration) { current_account.term_registrations.first }
  let(:current_account) { FactoryBot.create(:account, :student) }
  let(:submission_asset) { FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
  subject { FactoryBot.create(:submission_asset_rename, submission: submission, submission_asset: submission_asset, new_filename: "file2.txt") }

  describe 'attributes' do
    it 'has a submission_asset attribute' do
      expect(subject).to respond_to(:submission_asset)
      expect(subject).to respond_to(:submission_asset=)
    end

    it 'has a submission attribute' do
      expect(subject).to respond_to(:submission)
      expect(subject).to respond_to(:submission=)
    end

    it 'has a new_filename attribute' do
      expect(subject).to respond_to(:new_filename)
      expect(subject).to respond_to(:new_filename=)
    end

    it 'has a renamed_at attribute' do
      expect(subject).to respond_to(:renamed_at)
      expect(subject).to respond_to(:renamed_at=)
    end

    it 'has a filename_old attribute' do
      expect(subject).to respond_to(:filename_old)
      expect(subject).to respond_to(:filename_old=)
    end

    it 'has a renamed_by_id attribute' do
      expect(subject).to respond_to(:renamed_by)
      expect(subject).to respond_to(:renamed_by=)
    end
  end

  describe 'validates_presence' do
    it 'validates presence of new_filename' do
      expect(subject).to validate_presence_of(:new_filename)
    end

    it 'validates presence of renamed_at' do
      expect(subject).to validate_presence_of(:renamed_at)
    end

    it 'validates presence of filename_old' do
      expect(subject).to validate_presence_of(:filename_old)
    end

    it 'validates presence of renamed_by_id' do
      expect(subject).to validate_presence_of(:renamed_by)
    end
  end

  describe 'delegation' do
    it 'delegates id and submission to submission_asset' do
      expect(subject.id).to eq(submission_asset.id)
      expect(subject.submission).to eq(submission_asset.submission)
    end

    it 'delegates term to submission' do
      allow(subject).to receive(:submission_asset).and_return(submission_asset)
      allow(submission_asset).to receive(:submission).and_return(submission)

      expect(subject.term).to eq(term)
    end
  end

  describe '#save!' do
    context 'when valid' do
      before do
        allow(subject).to receive(:valid?).and_return(true)
        allow(subject).to receive(:set_default_new_filename)
        allow(submission_asset).to receive(:update).and_return(true)
      end

      it 'sets default filename and updates submission asset' do
        expect(subject).to receive(:set_default_new_filename)
        expect(subject.submission_asset).to receive(:update_attribute).with(:filename, subject.new_filename)
        subject.save!
      end
    end

    context 'when not valid' do
      before do
        allow(subject).to receive(:valid?).and_return(false)
      end

      it 'does not update submission asset' do
        expect(submission_asset).not_to receive(:update)
        subject.save!
      end
    end
  end

  describe "#new_filename_unique" do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }

    subject { FactoryBot.create(:submission_asset_rename, new_filename: nil) }
      it "is invalid without a new filename" do
      expect(subject).to_not be_valid
    end

    let(:submission_asset_1) { FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
    subject { FactoryBot.create(:submission_asset_rename, submission: submission, submission_asset: submission_asset_1, new_filename: "file2.txt") }
    it "is valid if new filename is not taken by any another asset or directory on the same directory lever" do
      expect(subject.errors[:new_filename]).to be_empty
    end

    let(:submission_asset_1) { FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
    let(:submission_asset_2) { FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file2.txt")) }
    subject { FactoryBot.create(:submission_asset_rename, submission: submission, submission_asset: submission_asset_1, new_filename: "file2.txt") }
    it "is not valid when the new filename is taken by another asset on the same directory level" do
      expect(subject).to_not be_valid
      expect(subject.errors[:new_filename]).to include("has already been taken")
    end

    let(:submission_asset_1) { FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
    let(:submission_asset_2) { FactoryBot.create(:submission_asset, submission: submission, path: "directory1/directory2", file: prepare_static_test_file("simple_submission.txt", rename_to: "file2.txt")) }
    subject { FactoryBot.create(:submission_asset_rename, submission: submission, submission_asset: submission_asset_1, new_filename: "directory2") }
    it "is not valid when the new filename is taken by another directory on the same directory level" do
      expect(subject).to_not be_valid
      expect(subject.errors[:new_filename]).to include("has already been taken")
    end

    let(:submission_asset_1) { FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
    let(:submission_asset_2) { FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file2.txt")) }
    subject { FactoryBot.create(:submission_asset_rename, submission: submission, submission_asset: submission_asset_1, new_filename: "file2.txt") }
    it "is valid to have two files with the same filename if they are on different directory levels" do
      expect(subject.errors[:new_filename]).to be_empty
    end
  end

  describe '#set_default_new_filename' do
    context 'when new_filename is nil' do
      it 'sets new_filename to submission_asset.filename' do
        allow(subject).to receive(:submission_asset).and_return(submission_asset)
        subject.new_filename = nil
        subject.set_default_new_filename
        expect(subject.new_filename).to eq(submission_asset.filename)
      end
    end

    context 'when new_filename is already set' do
      it 'does not change new_filename' do
        subject.new_filename = 'existing_filename.txt'
        subject.set_default_new_filename
        expect(subject.new_filename).to eq('existing_filename.txt')
      end
    end
  end

end
