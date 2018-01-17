require 'rails_helper'

RSpec.describe Rating do
  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:min_value).of_type(:integer) }
    it { is_expected.to have_db_column(:max_value).of_type(:integer) }
    it { is_expected.to have_db_column(:row_order).of_type(:integer) }
    it { is_expected.to have_db_column(:multiplication_factor).of_type(:float) }
    it { is_expected.to have_db_column(:automated_checker_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:bulk).of_type(:boolean) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'methods' do
    let(:rating_subclasses) do
      [
        Ratings::FixedPointsDeductionRating,
        Ratings::FixedPercentageDeductionRating,
        Ratings::VariablePointsDeductionRating,
        Ratings::VariablePercentageDeductionRating,
        Ratings::PerItemPointsDeductionRating,
        Ratings::PerItemPointsRating,
        Ratings::FixedBonusPointsRating,
        Ratings::VariableBonusPointsRating,
        Ratings::PlagiarismRating
      ]
    end

    describe '.instantiable_subclasses' do
      it "returns an array of all the subclasses" do
        expect(described_class.instantiable_subclasses).to match_array(rating_subclasses)
      end
    end

    describe '.new_from_type' do
      it 'returns a new rating of given type' do
        rating_subclasses.each do |subclass|
          expect(described_class.new_from_type({type: subclass.name, title: "test"})).to be_a(subclass)
        end
      end

      it 'sets the given attributes' do
        instance = described_class.new_from_type({type: rating_subclasses.first.name, title: "test"})

        expect(instance.title).to eq("test")
      end

      it 'raises a NoMethodError if subclass is unknown' do
        expect do
          described_class.new_from_type({type: "unknown", title: "test"})
        end.to raise_error(NoMethodError)
      end
    end
  end
end