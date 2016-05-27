require 'rails_helper'

RSpec.describe SubmissionFolder do
  it { is_expected.to be_a(ActiveModel::Model) }

  describe '#path=' do
    it 'assigns path' do
      subject.path = "test/path"

      expect(subject.path).to eq("test/path")
    end
  end

  describe '#name=' do
    it 'assigns name' do
      subject.name = "filename"

      expect(subject.name).to eq("filename")
    end
  end

  describe '#submission=' do
    let(:submission) { FactoryGirl.build(:submission) }
    it 'assigns submission' do
      subject.submission = submission

      expect(subject.submission).to eq(submission)
    end
  end

  describe '#path' do
    it 'returns the given path' do
      subject.path = "path"
      expect(subject.path).to eq("path")
    end

    it 'returns an empty string if path is not present' do
      subject.path = nil

      expect(subject.path).to eq("")
    end

    it 'removes submission/ at the beginning' do
      subject.path = "submission/test"

      expect(subject.path).to eq("test")
    end
  end

  describe '#full_path' do
    it 'returns an the path if name is blank' do
      subject.name = ""
      subject.path = "test/path"

      expect(subject.full_path).to eq("test/path")
    end

    it 'returns the name if the path is blank' do
      subject.name = "test/folder"
      subject.path = ""

      expect(subject.full_path).to eq("test/folder")
    end

    it 'returns an empty string if name and path are blank' do
      subject.name = ""
      subject.path = ""

      expect(subject.full_path).to eq("")
    end

    it 'joins the name and path' do
      subject.name = "folder"
      subject.path = "test"

      expect(subject.full_path).to eq("test/folder")
    end

    it 'calls SubmissionAsset.normalize_path' do
      expect(SubmissionAsset).to receive(:normalize_path).with("folder/path")

      subject.name = "path"
      subject.path = "folder"

      subject.full_path
    end
  end

  describe '#path_available?' do
    let(:submission) { FactoryGirl.build(:submission) }

    it 'tests if path is available through SubmissionAsset.path_exists?' do
      expect(SubmissionAsset).to receive(:path_exists?).with("folder/test/path").and_return(false)
      subject.submission = submission
      subject.name = "path"
      subject.path = "folder/test"

      expect(subject.path_available?).to be_truthy
    end
  end
end
