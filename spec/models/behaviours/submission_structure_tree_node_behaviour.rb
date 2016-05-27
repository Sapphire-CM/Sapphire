require 'rails_helper'

RSpec.shared_examples 'submission structure tree node' do
  it { is_expected.to respond_to(:parent) }
  it { is_expected.to respond_to(:directory?) }
  it { is_expected.to respond_to(:file?) }
  it { is_expected.to respond_to(:root?) }
  it { is_expected.to respond_to(:size) }
  it { is_expected.to respond_to(:mtime) }
  it { is_expected.to respond_to(:icon) }
  it { is_expected.to respond_to(:path) }
  it { is_expected.to respond_to(:path_without_root) }
  it { is_expected.to respond_to(:relative_path) }
  it { is_expected.to respond_to(:path_components) }
  it { is_expected.to respond_to(:parents) }
  it { is_expected.to respond_to(:ancestors) }

  describe 'attr_accessor parent' do
    let(:parent) { SubmissionStructure::TreeNode.new }

    it 'assigns and returns parent' do
      subject.parent = parent
      expect(subject.parent).to eq(parent)
    end
  end

  describe '#root?' do
    let(:parent) { SubmissionStructure::TreeNode.new }

    it 'returns true if parent is blank' do
      subject.parent = nil
      expect(subject.root?).to be_truthy
    end

    it 'returns false if parent is set' do
      subject.parent = parent
      expect(subject.root?).to be_falsey
    end
  end

  context "with relatives" do
    class TestTreeNode < SubmissionStructure::TreeNode
      attr_accessor :name, :parent

      def initialize(name, parent = nil)
        super()
        @name = name
        @parent = parent
      end
    end
    let!(:grand_parent) { TestTreeNode.new("grand_parent") }
    let!(:uncle) { TestTreeNode.new("uncle", grand_parent) }
    let!(:parent) { TestTreeNode.new("parent", grand_parent) }

    before :each do
      subject.instance_variable_set("@name", "name")
      subject.parent = parent
    end

    describe '#path' do
      it 'returns the joined path' do
        expect(subject.path).to eq("grand_parent/parent/name")
      end
    end


    describe '#path_without_root' do
      it 'returns an the path without the root element' do
        expect(subject.path_without_root).to eq("parent/name")
      end
    end

    describe '#relative_path' do
      it 'returns only the name without initial slash' do
        grand_parent.name = "///grand_parent"

        expect(subject.relative_path).to eq("grand_parent/parent/name")
      end
    end

    describe '#path_components' do
      let(:components) { %w(grand_parent parent name) }

      it 'returns all components of its path' do
        expect(subject.path_components).to match(components)
      end
    end

    describe '#parents' do
      it 'returns its parents and itself' do
        expect(subject.parents).to match([grand_parent, parent, subject])
      end
    end

    describe '#ancestors' do
      it 'returns its parents' do
        expect(subject.ancestors).to match([grand_parent, parent])
      end
    end

  end

  context 'without relatives' do
    before :each do
      subject.instance_variable_set("@name", "name")
      subject.parent = nil
    end

    describe '#path' do
      it "returns an the name" do
        expect(subject.path).to eq("name")
      end
    end

    describe '#path_without_root' do
      it 'returns an empty string' do
        expect(subject.path_without_root).to eq("")
      end
    end

    describe '#relative_path' do
      it 'returns only the name without initial slash' do
        subject.instance_variable_set("@name", "///name")

        expect(subject.relative_path).to eq("name")
      end
    end

    describe '#path_components' do
      it 'returns an array with its name inside' do
        expect(subject.path_components).to match(%w(name))
      end
    end

    describe '#parents' do
      it 'returns an array with itself inside' do
        expect(subject.parents).to eq([subject])
      end
    end

    describe '#ancestors' do
      it 'returns an empty array' do
        expect(subject.ancestors).to eq([])
      end
    end
  end
end
