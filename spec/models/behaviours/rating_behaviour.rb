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
    let(:factory_name) { rating_factory(described_class) }

    describe '.automated_ratings' do
      let!(:automated_ratings) { FactoryBot.create_list(factory_name, 2, automated_checker_identifier: "automated") }
      let!(:non_automated_nil_ratings) { FactoryBot.create_list(factory_name, 2, automated_checker_identifier: nil) }
      let!(:non_automated_blank_ratings) { FactoryBot.create_list(factory_name, 2, automated_checker_identifier: "") }

      it 'returns ratings where automated_checker_identifier is present' do
        expect(described_class.automated_ratings).to match_array(automated_ratings)
      end
    end

    describe '.bulk' do
      let!(:bulk_ratings) { FactoryBot.create_list(factory_name, 2, bulk: true) }
      let!(:non_bulk_ratings) { FactoryBot.create_list(factory_name, 2, bulk: false) }

      it 'returns ratings where bulk is true' do
        expect(described_class.bulk).to match_array(bulk_ratings)
      end
    end
  end

  describe 'methods' do
    describe '#evaluation_class' do
      it 'returns a subclass of Evaluation' do
        expect(subject.evaluation_class < Evaluation).to be_truthy
      end
    end

    describe '#policy_class' do
      it 'returns RatingPolicy' do
        expect(subject.policy_class).to eq(RatingPolicy)
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

  describe 'callbacks' do
    let(:factory_name) { rating_factory(described_class) }

    describe 'setting needs review' do
      let(:exercise) { FactoryBot.create(:exercise) }
      let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }

      context 'existing submissions' do
        let(:submissions) { FactoryBot.create_list(:submission, 3, exercise: exercise) }
        let(:evaluations) { submissions.map(&:submission_evaluation).map(&:evaluations).flatten }

        it 'sets needs_review of the evaluations associated with the rating if title is changed' do
          subject = FactoryBot.create(factory_name, rating_group: rating_group)

          expect(submissions.length).to eq(3)
          subject.update!(title: "Another Rating")

          evaluations.each do |evaluation|
            expect(evaluation.needs_review?).to be_truthy
          end
        end

        it 'sets needs_review of the evaluations after creating a rating' do
          expect(submissions.length).to eq(3)
          subject = FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group)

          evaluations.each do |evaluation|
            expect(evaluation.needs_review?).to be_truthy
          end
        end
      end

      context 'new submissions' do
        let(:submissions) { FactoryBot.create_list(:submission, 3, exercise: exercise) }
        let(:evaluations) { submissions.map(&:submission_evaluation).map(&:evaluations).flatten }

        it 'doesn\'t set needs_review of the evaluations associated of submissions created after the rating' do
          subject = FactoryBot.create(factory_name, rating_group: rating_group)

          expect(submissions.length).to eq(3)
          evaluations.each do |evaluation|
            expect(evaluation.needs_review).to be_falsey
          end
        end
      end
    end
  end
end
