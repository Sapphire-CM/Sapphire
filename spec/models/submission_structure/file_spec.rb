require 'rails_helper'
require 'models/behaviours/submission_structure_tree_node_behaviour'

RSpec.describe SubmissionStructure::File do
  let(:submission_asset) { FactoryGirl.build(:submission_asset) }
  subject { described_class.new(submission_asset) }

  it_behaves_like "submission structure tree node"

  describe '#file?' do
    it "returns true" do
      expect(subject.file?).to be_truthy
    end
  end

  describe '#directory?' do
    it 'returns false' do
      expect(subject.directory?).to be_falsey
    end
  end

  describe '#size' do
    it 'returns the filesystem size of the submission_asset' do
      expect(submission_asset).to receive(:filesystem_size).and_return(1337)

      expect(subject.size).to eq(1337)
    end
  end

  describe '#icon' do
    it 'returns "photo" for images' do
      SubmissionAsset::Mime::IMAGES.each do |ct|
        submission_asset.content_type = ct

        expect(subject.icon).to eq("photo")
      end
    end

    it 'returns "page-pdf" for pdfs' do
      submission_asset.content_type = SubmissionAsset::Mime::PDF

      expect(subject.icon).to eq("page-pdf")
    end

    it 'returns "page-doc" for documents' do
      [SubmissionAsset::Mime::PLAIN_TEXT, SubmissionAsset::Mime::HTML].each do |ct|
        submission_asset.content_type = ct

        expect(subject.icon).to eq("page-doc")
      end
    end

    it 'returns "email" for emails and newsgroup posts' do
      [SubmissionAsset::Mime::EMAIL, SubmissionAsset::Mime::NEWSGROUP_POST].each do |ct|
        submission_asset.content_type = ct

        expect(subject.icon).to eq("email")
      end
    end

    it 'returns "page-multiple" for archives' do
      SubmissionAsset::Mime::ARCHIVES.each do |ct|
        submission_asset.content_type = ct

        expect(subject.icon).to eq("page-multiple")
      end
    end

    it 'returns "page" for unknown content types' do
      submission_asset.content_type = "unknown"

      expect(subject.icon).to eq("page")
    end
  end
end
