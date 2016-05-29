require 'rails_helper'

RSpec.describe SubmissionStructureService do
  describe '.parse_submission' do
    let(:submission) { FactoryGirl.create(:submission) }
    let!(:submission_assets) do
      [
        FactoryGirl.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt")),
        FactoryGirl.create(:submission_asset, submission: submission, path: "test", file: prepare_static_test_file("simple_submission.txt")),
        FactoryGirl.create(:submission_asset, submission: submission, path: "test", file: prepare_static_test_file("simple_submission.txt", rename_to: "simple_submission_2.txt"))
      ]
    end

    it 'parses the submission into a directory tree' do
      submission.reload
      tree = described_class.parse_submission(submission)

      expect(tree).to be_a(SubmissionStructure::Directory)
      expect(tree.name).to eq("/")
      expect(tree.entries.length).to eq(2)

      tree.entries.each do |entry|
        expect(entry).to be_a(SubmissionStructure::TreeNode)
      end

      top_level_file = tree.entries.first
      expect(top_level_file).to be_a(SubmissionStructure::File)
      expect(top_level_file.name).to eq("simple_submission.txt")

      directory = tree.entries.last
      expect(directory).to be_a(SubmissionStructure::Directory)
      expect(directory.name).to eq("test")
      expect(directory.entries.length).to eq(2)

      expect(directory.entries.map(&:name)).to match_array(%w(simple_submission.txt simple_submission_2.txt))
      directory.entries.each do |entry|
        expect(entry).to be_a(SubmissionStructure::File)
      end
    end
  end
end
