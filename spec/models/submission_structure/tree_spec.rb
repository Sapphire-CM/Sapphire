require 'rails_helper'

RSpec.describe SubmissionStructure::Tree do
  describe 'delegation' do
    it { is_expected.to delegate_method(:resolve).to(:base_dir) }
    it { is_expected.to delegate_method(:submission_assets).to(:submission) }
  end

  describe 'initialization' do
    let(:submission) { FactoryGirl.build(:submission) }

    it "does not parse the submission" do
      expect(submission).not_to receive(:submission_assets)

      described_class.new(submission: submission)
    end
  end

  describe 'methods' do
    let(:submission) { FactoryGirl.create(:submission, :with_basic_structure) }
    let(:submission_assets) { submission.submission_assets }
    let(:base_directory_name) { "Fancy Directory" }
    subject { described_class.new(submission: submission, base_directory_name: base_directory_name) }

    describe '#base_dir' do
      it 'parses the submission structure' do
        submission.reload

        expect(submission).to receive(:submission_assets).and_call_original

        base_dir = subject.base_dir

        expect(base_dir).to be_a(SubmissionStructure::Directory)
        expect(base_dir.name).to eq("Fancy Directory")
        expect(base_dir.entries.map(&:name)).to match_array(%w(file1.txt nested very))

        base_dir.entries.each do |entry|
          expect(entry).to be_a(SubmissionStructure::TreeNode)
        end

        directory = base_dir.directories.sort_by(&:name).first
        expect(directory).to be_a(SubmissionStructure::Directory)
        expect(directory.name).to eq("nested")
        expect(directory.entries.map(&:name)).to match_array(%w(file2.txt file3.txt further))
        expect(directory.files.map(&:name)).to match_array(%w(file2.txt file3.txt))
        expect(directory.directories.map(&:name)).to match_array(%w(further))

        directory.files.each do |entry|
          expect(entry).to be_a(SubmissionStructure::File)
        end
      end

      it 'sets the base_directory_name' do
        expect(subject.base_dir.name).to eq(base_directory_name)
      end

      it 'does not raise an error if base_directory_name is nil' do
        subject.base_directory_name = nil

        expect do
          subject.base_dir
        end.not_to raise_error
      end
    end

    describe '#submission' do
      it 'returns the submission' do
        expect(subject.submission).to eq(submission)
      end
    end
  end
end