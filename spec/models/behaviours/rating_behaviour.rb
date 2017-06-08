require 'rails_helper'

RSpec.shared_examples 'a rating' do
  describe 'inheritence' do
    it 'is a subclass of rating' do
      expect(subject).to be_a(Rating)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:rating_group) }
    it { is_expected.to have_many(:evaluations).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rating_group) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:type) }
  end

  describe 'scoping' do
    describe '.automated'
  end

  describe 'methods' do
    describe '#evaluation_class' do
      it 'returns a subclass of Evaluation' do
        expect(subject.evaluation_class < Evaluation).to be_truthy
      end
    end

    describe '#automatically_checked?' do
      it 'returns true if automated_checker_identifier is set' do
        subject.automated_checker_identifier = "An automated checker"

        expect(subject.automatically_checked?).to be_truthy
      end

      it 'returns false if automated_checker_identifier is nil' do
        subject.automated_checker_identifier = nil

        expect(subject.automatically_checked?).to be_falsey
      end
    end

    describe '#points_value?' do
      it { is_expected.to respond_to(:points_value?) }

      it 'does not raise an error' do
        expect do
          subject.points_value?
        end.not_to raise_error
      end
    end

    describe '#percentage_value?' do
      it { is_expected.to respond_to(:percentage_value?) }

      it 'does not raise an error' do
        expect do
          subject.percentage_value?
        end.not_to raise_error
      end
    end

    describe '#from_updated_type' do
      subject { Rating.new }

      it 'returns a rating of the updated rating type class' do
        expect(subject).to be_instance_of(Rating)

        subject.type = described_class.name
        expect(subject.from_updated_type).to be_instance_of(described_class)
      end

      it 'raises an error if type is not a rating subclass' do
        expect(subject).to be_instance_of(Rating)
        subject.type = Array.name

        expect do
          subject.from_updated_type
        end.to raise_error(ArgumentError)
      end
    end
  end
end
