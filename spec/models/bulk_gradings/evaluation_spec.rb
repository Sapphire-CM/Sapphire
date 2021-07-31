require 'rails_helper'

RSpec.describe BulkGradings::Evaluation, :doing do
  describe 'initialization' do
    let(:rating) { instance_double(Rating) }
    let(:value) { 42 }
    let(:item) { instance_double(BulkGradings::Item) }

    it 'sets given attributes' do
      subject = described_class.new({rating: rating, value: value, item: item})

      expect(subject.rating).to eq(rating)
      expect(subject.value).to eq(value)
      expect(subject.item).to eq(item)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_presence_of(:item) }

    describe 'value' do
      let(:rating) { instance_double(Rating) }
      let(:evaluation_class) { double(Evaluation) }
      let(:evaluation) { instance_double(Evaluation) }

      subject { described_class.new(rating: rating) }

      before :each do
        allow(rating).to receive(:evaluation_class).and_return(evaluation_class)
        allow(evaluation_class).to receive(:new).and_return(evaluation)
      end

      it 'delegates value validation to a new evaluation' do
        allow(evaluation).to receive(:errors).and_return({value: ["is invalid"]})
        expect(evaluation).to receive(:valid?).and_return(false)

        subject.valid?

        expect(subject.errors[:value]).to include("is invalid")
      end

      it 'does not add an error to value if evaluation does not return an error' do
        expect(evaluation).to receive(:valid?).and_return(true)

        subject.valid?

        expect(subject.errors[:value]).to be_blank
      end

      it 'does not raise an error if rating is not set' do
        subject.rating = nil

        expect do
          subject.valid?
        end.not_to raise_error
      end
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:id).to(:rating).with_prefix }
    it { is_expected.to delegate_method(:bulk).to(:item) }
    it { is_expected.to delegate_method(:exercise).to(:item) }
  end

  describe 'methods' do
    let(:bulk) { instance_double(BulkGradings::Bulk) }
    let(:item) { instance_double(BulkGradings::Item, bulk: bulk) }

    describe '#rating_id=' do
      subject { described_class.new(item: item) }

      let(:rating) { instance_double(Rating) }

      it 'sets the rating by retrieving it from the bulk' do
        expect(bulk).to receive(:rating_with_id).with("42").and_return(rating)

        subject.rating_id = "42"
        expect(subject.rating).to eq(rating)
      end
    end

    describe '#value?' do
      subject { described_class.new(rating: rating) }

      context 'fixed rating' do
        let(:rating) { FactoryBot.build(:fixed_points_deduction_rating) }

        it 'is false if value is nil' do
          subject.value = nil
          expect(subject.value?).to be_falsey
        end

        it 'is false if value is ""' do
          subject.value = ""
          expect(subject.value?).to be_falsey
        end

        it 'is true if value is 0' do
          subject.value = 0
          expect(subject.value?).to be_truthy
        end

        it 'is true if value is positive' do
          subject.value = 21
          expect(subject.value?).to be_truthy
        end

        it 'is true if value is negative' do
          subject.value = -21
          expect(subject.value?).to be_truthy
        end

        it 'is true if value is "0"' do
          subject.value = "0"
          expect(subject.value?).to be_truthy
        end

        it 'is true if value is "1"' do
          subject.value = "1"
          expect(subject.value?).to be_truthy
        end
      end

      context 'variable rating' do
        let(:rating) { FactoryBot.build(:variable_points_deduction_rating) }

        it 'is false if value is nil' do
          subject.value = nil
          expect(subject.value?).to be_falsey
        end

        it 'is false if value is 0' do
          subject.value = 0
          expect(subject.value?).to be_falsey
        end

        it 'is true if value is positive' do
          subject.value = 21
          expect(subject.value?).to be_truthy
        end

        it 'is true if value is negative' do
          subject.value = -21
          expect(subject.value?).to be_truthy
        end

        it 'is false if value is "0"' do
          subject.value = "0"
          expect(subject.value?).to be_falsey
        end

        it 'is true if value is "1"' do
          subject.value = "1"
          expect(subject.value?).to be_truthy
        end
      end
    end

    describe '#save' do
      let(:staff_account) { FactoryBot.create(:account, :admin) }
      let(:term) { FactoryBot.create(:term) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
      let!(:ratings) { FactoryBot.create_list(:fixed_points_deduction_rating, 3, rating_group: rating_group) }
      let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }
      let(:rating) { ratings.second }
      let(:evaluation) { rating.evaluations.reload.for_submission(submission).first }

      let(:bulk) { BulkGradings::Bulk.new(exercise: exercise, account: staff_account) }
      let(:item) { BulkGradings::Item.new(bulk: bulk, subject: term_registration, submission: submission) }

      subject { described_class.new(item: item, rating: rating, value: 1) }

      it 'updates the associated evaluation' do
        evaluation.update(value: 0)

        subject.save

        evaluation.reload
        expect(evaluation.value).to eq(1)
      end
    end
  end
end
