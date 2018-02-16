require 'rails_helper'
require 'models/behaviours/submission_structure_tree_node_behaviour'

RSpec.describe SubmissionStructure::Directory do
  subject { described_class.new("fancy name") }

  it_behaves_like "submission structure tree node"

  describe '#directory?' do
    it "returns true" do
      expect(subject.directory?).to be_truthy
    end
  end

  describe '#file?' do
    it "returns false" do
      expect(subject.file?).to be_falsey
    end
  end

  describe '#<<' do
    it 'adds the given entry to the folder structure' do
      node = TestTreeNode.new("nodename")
      subject << node

      expect(subject['nodename']).to eq(node)
      expect(node.parent).to eq(subject)
    end
  end

  context 'with entries' do
    let!(:direct_decendants) do
      [].tap do |decendants|
        3.times do |i|
          node = described_class.new("node-#{i + 1}")
          decendants << node
          subject << node
        end
      end
    end

    let!(:further_decendants) do
      direct_decendants.map do |parent|
        [].tap do |decendants|
          3.times do |i|
            node = described_class.new("#{parent.name}-#{i + 1}", parent)
            decendants << node
            subject << node
          end
        end
      end
    end

    let(:names) { direct_decendants.map(&:name) + further_decendants.flat_map { |d| d.map(&:name) } }

    describe '#entries' do
      it 'returns the direct decendants' do
        expect(subject.entries.map(&:name)).to match_array(names)
      end
    end

    describe '#[]' do
      it 'returns requested nodes' do
        expect(subject["node-1"].name).to eq(direct_decendants.first.name)
      end
    end

    describe '#resolve' do
      it 'returns requested node' do
        expect(subject.resolve("node-1").name).to eq(direct_decendants.first.name)
        expect(subject.resolve("node-1/node-1-1").name).to eq(further_decendants.first.first.name)
      end
    end

    describe '#submission_assets' do
      let(:submission_asset) { FactoryGirl.create(:submission_asset) }
      let(:file_node) { SubmissionStructure::File.new(submission_asset) }

      it 'returns the submission_assets' do
        subject << file_node

        expect(subject.submission_assets).to eq([submission_asset])
      end
    end

    describe '#sorted_entries' do
      it 'returns a sorted list of entries' do
        expect(subject.sorted_entries.map(&:name)).to eq(names.sort)
      end
    end

    describe '#mtime' do
      let(:now) { Time.now.to_i + 4.hours }

      it 'returns the maximum mtime' do
        allow(direct_decendants.first).to receive(:mtime).and_return(now)

        expect(subject.mtime).to eq(now)
      end
    end
  end


  context 'without entries' do
    describe '#[]' do
      it 'returns nil' do
        expect(subject["does-not-exist"]).to be_nil
      end
    end

    describe '#resolve' do
      it 'returns a new directory if create_directories is true' do
        expect do
          tree = subject.resolve("does/not-exist", create_directories: true)
          expect(tree.parent.parent).to eq(subject)
          expect(tree.name).to eq("not-exist")
        end.not_to raise_error
      end

      it 'raises an error if create_directories is false' do
        expect do
          subject.resolve("does/not-exist", create_directories: false)
        end.to raise_error(SubmissionStructure::FileNotFound)
      end
    end

    describe '#submission_assets' do
      it 'returns an empty array' do
        expect(subject.submission_assets).to eq([])
      end
    end

    describe '#entries' do
      it 'returns an empty array' do
        expect(subject.entries).to eq([])
      end
    end

    describe '#sorted_entries' do
      it 'returns an empty array' do
        expect(subject.sorted_entries).to eq([])
      end
    end

    describe '#mtime' do
      it 'returns 0' do
        expect(subject.mtime).to eq(nil)
      end
    end
  end

  describe '#icon' do
    it 'returns "folder"' do
      expect(subject.icon).to eq("folder")
    end
  end
end
