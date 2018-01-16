require 'rails_helper'

RSpec.describe SubmissionBulk::Bulk do
  let(:exercise) { instance_double(Exercise) }
  let(:account) { instance_double(Account) }

  subject { described_class.new(exercise: exercise, account: account) }

  describe 'initialization' do
    let(:attributes) { {exercise: exercise, account: account} }

    it 'sets given attributes' do
      subject = described_class.new(attributes)

      attributes.each do |key, value|
        expect(subject.send(key)).to eq(value)
      end
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:group_submission?).to(:exercise) }
    it { is_expected.to delegate_method(:solitary_submission?).to(:exercise) }
  end

  describe 'validations' do
    describe 'item validation' do
      let(:blank_item) { instance_double(SubmissionBulk::Item).tap { |item| allow(item).to receive(:values?).and_return(false) } }
      let(:filled_item_1) { instance_double(SubmissionBulk::Item).tap { |item| allow(item).to receive(:values?).and_return(true) } }
      let(:filled_item_2) { instance_double(SubmissionBulk::Item).tap { |item| allow(item).to receive(:values?).and_return(true) } }

      let(:items) { [filled_item_1, filled_item_2, blank_item] }
      let(:filled_items) { [filled_item_1, filled_item_2]}

      before :each do
        allow(subject).to receive(:items).and_return(items)
        items.each do |item|
          allow(item).to receive(:valid?).and_return(true)
        end
      end

      it 'adds a validation error if an item is not valid' do
        allow(filled_item_2).to receive(:valid?).and_return(false)

        subject.valid?
        expect(subject.errors[:items]).not_to be_blank
      end

      it 'does not add a validation error if all items are valid' do
        subject.valid?
        expect(subject.errors[:items]).to be_blank
      end

      it "validates all filled items" do
        filled_items.each do |item|
          expect(item).to receive(:valid?).and_return(false)
        end

        subject.valid?
      end

      it "does not validate blank items" do
        expect(blank_item).not_to receive(:valid?)

        subject.valid?
      end
    end
  end

  describe 'methods' do
    describe '#items_attributes=' do
      let(:exercise) { FactoryGirl.build(:exercise) }
      let(:item_1_attributes) { {subject_id: 1, evaluations_attributes: {"0" => {rating_id: 1, value: 1}}} }
      let(:item_2_attributes) { {subject_id: 2, evaluations_attributes: {"0" => {rating_id: 1, value: 1}}} }
      let(:item_3_attributes) { {subject_id: 3, evaluations_attributes: {"0" => {rating_id: 1, value: 1}}} }

      let(:items_attributes) { {"0" => item_1_attributes, "1" => item_2_attributes, "2" => item_3_attributes} }

      let(:item_1) { instance_double(SubmissionBulk::Item) }
      let(:item_2) { instance_double(SubmissionBulk::Item, subject_id: 2) }
      let(:item_3) { instance_double(SubmissionBulk::Item) }

      let(:items) { [item_1, item_2, item_3]}

      let(:submission_subject) { instance_double(TermRegistration, id: 2) }
      let(:subjects_finder) { instance_double(SubmissionBulk::SubjectsFinder) }

      it 'initialize items with given attributes' do
        expect(SubmissionBulk::Item).to receive(:new).with(item_1_attributes.merge(bulk: subject)).and_return(item_1)
        expect(SubmissionBulk::Item).to receive(:new).with(item_2_attributes.merge(bulk: subject)).and_return(item_2)
        expect(SubmissionBulk::Item).to receive(:new).with(item_3_attributes.merge(bulk: subject)).and_return(item_3)

        allow(item_1).to receive(:subject_id?).and_return(false)
        allow(item_2).to receive(:subject_id?).and_return(false)
        allow(item_3).to receive(:subject_id?).and_return(false)

        subject.items_attributes = items_attributes

        expect(subject.items).to match_array(items)
      end

      it 'sets subjects for items with a subject_ids but without subject' do
        allow(SubmissionBulk::Item).to receive(:new).with(item_1_attributes.merge(bulk: subject)).and_return(item_1)
        allow(SubmissionBulk::Item).to receive(:new).with(item_2_attributes.merge(bulk: subject)).and_return(item_2)
        allow(SubmissionBulk::Item).to receive(:new).with(item_3_attributes.merge(bulk: subject)).and_return(item_3)
        allow(SubmissionBulk::SubjectsFinder).to receive(:new).and_return(subjects_finder)
        allow(item_1).to receive(:subject_id?).and_return(false)
        allow(item_2).to receive(:subject_id?).and_return(true)
        allow(item_3).to receive(:subject_id?).and_return(false)

        allow(item_2).to receive(:subject?).and_return(false)

        expect(subjects_finder).to receive(:find).with([2]).and_return([submission_subject])
        expect(item_2).to receive(:subject=).with(submission_subject).and_return(true)

        subject.items_attributes = items_attributes
      end
    end

    describe '#ratings' do
      let(:exercise) { FactoryGirl.create(:exercise) }
      let!(:bulk_ratings) { FactoryGirl.create_list(:fixed_points_deduction_rating, 2, exercise: exercise, bulk: true) }
      let!(:non_bulk_ratings) { FactoryGirl.create_list(:fixed_points_deduction_rating, 2, exercise: exercise, bulk: false) }
      let!(:other_ratings) { FactoryGirl.create_list(:fixed_points_deduction_rating, 2, bulk: true) }

      it 'returns the exercise\'s ratings' do
        expect(subject.ratings).to match_array(bulk_ratings)
      end
    end

    describe '#rating_with_id' do
      let(:rating_1) { instance_double(Rating, id: 1) }
      let(:rating_2) { instance_double(Rating, id: 2) }

      let(:ratings) { [rating_1, rating_2] }

      before :each do
        allow(subject).to receive(:ratings).and_return(ratings)
      end

      it 'finds ratings with given id as integer' do
        expect(subject.rating_with_id(1)).to eq(rating_1)
      end

      it 'finds ratings with given id as string' do
        expect(subject.rating_with_id("2")).to eq(rating_2)
      end

      it 'returns nil if id is unknown' do
        expect(subject.rating_with_id("42")).to be_nil
      end

      it 'does not raise an error if id is nil' do
        expect do
          subject.rating_with_id(nil)
        end.not_to raise_error
      end
    end

    describe '#items' do
      let(:items) { [instance_double(SubmissionBulk::Item)] }

      it 'returns items' do
        subject.items = items

        expect(subject.items).to eq(items)
      end

      it 'returns an empty array if no item attributes were set' do
        expect(subject.items).to eq([])
      end
    end

    describe '#ensure_blank!' do
      let(:blank_item) { instance_double(SubmissionBulk::Item, :"values?" => false) }
      let(:item_with_values) { instance_double(SubmissionBulk::Item, :"values?" => true) }

      it 'adds a blank item to the collection if items are empty' do
        subject.items = []
        expect(subject).to receive(:blank_item).and_return(blank_item)
        expect do
          subject.ensure_blank!
        end.to change(subject.items, :length).by(1)

        expect(subject.items).to match([blank_item])
      end

      it 'adds a blank item to the collection if last item has values' do
        subject.items = [item_with_values]

        expect(subject).to receive(:blank_item).and_return(blank_item)
        expect do
          subject.ensure_blank!
        end.to change(subject.items, :length).by(1)

        expect(subject.items).to match([item_with_values, blank_item])
      end

      it 'does not add an item to the collection if the last item does not have any values' do
        subject.items = [blank_item]

        expect(subject).not_to receive(:blank_item)
        expect do
          subject.ensure_blank!
        end.not_to change(subject.items, :length)
      end
    end

    describe '#blank_item' do
      let(:item) { instance_double(SubmissionBulk::Item) }

      it 'returns a blank SubmissionBulk::Item' do
        expect(SubmissionBulk::Item).to receive(:new).with(bulk: subject).and_return(item)

        expect(subject.blank_item).to eq(item)
      end

      it 'returns an item where bulk is set to subject' do
        expect(subject.blank_item.bulk).to eq(subject)
      end
    end

    describe '#save' do
      let(:exercise) { FactoryGirl.build(:exercise) }

      let(:item_1) { instance_double(SubmissionBulk::Item, subject: subject_1) }
      let(:item_2) { instance_double(SubmissionBulk::Item, subject: subject_2) }
      let(:item_3) { instance_double(SubmissionBulk::Item, subject: subject_3) }
      let(:items) { [item_1, item_2, item_3] }

      let(:subject_1) { instance_double(TermRegistration) }
      let(:subject_2) { instance_double(TermRegistration) }
      let(:subject_3) { instance_double(TermRegistration) }
      let(:subjects) { [subject_1, subject_2, subject_3]}

      let(:subject_2_submission) { instance_double(Submission) }
      let(:submissions_finder) { instance_double(SubmissionBulk::SubmissionsFinder) }

      it 'raises an error if there are validation errors' do
        allow(subject).to receive(:valid?).and_return(false)

        expect do
          subject.save
        end.to raise_error(SubmissionBulk::BulkNotValid)
      end

      it 'sets existing submissions on items' do
        allow(subject).to receive(:items).and_return(items)
        allow(SubmissionBulk::SubmissionsFinder).to receive(:new).and_return(submissions_finder)
        allow(submissions_finder).to receive(:find_submissions_for_subjects).with(subjects).and_return({subject_2 => subject_2_submission})

        items.each do |item|
          allow(item).to receive(:values?).and_return(true)
          allow(item).to receive(:valid?).and_return(true)
          allow(item).to receive(:save)
        end

        expect(item_2).to receive(:submission=).with(subject_2_submission)

        subject.save
      end

      it 'calls #save on items with values' do
        allow(subject).to receive(:valid?).and_return(true)
        allow(subject).to receive(:items).and_return(items)

        allow(item_1).to receive(:values?).and_return(true)
        allow(item_2).to receive(:values?).and_return(true)
        allow(item_3).to receive(:values?).and_return(false)

        items.each do |item|
          allow(item).to receive(:subject).and_return(nil)
        end

        expect(item_1).to receive(:save)
        expect(item_2).to receive(:save)
        expect(item_3).not_to receive(:save)

        subject.save
      end
    end
  end
end
