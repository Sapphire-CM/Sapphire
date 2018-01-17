require 'rails_helper'

RSpec.describe SubmissionBulk::Item do
  let(:account) { instance_double(Account) }
  let(:exercise) { instance_double(Exercise) }
  let(:bulk) { instance_double(SubmissionBulk::Bulk, account: account, exercise: exercise) }

  describe 'initialization' do
    let(:subject_id) { 42 }
    let(:subject) { instance_double(TermRegistration) }
    let(:submission) { instance_double(Submission) }

    let(:attributes) { {bulk: bulk, subject_id: subject_id, subject: subject, submission: submission} }

    it 'sets given attributes' do
      subject = described_class.new(attributes)

      attributes.each do |key, value|
        expect(subject.send(key)).to eq(value)
      end
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:exercise).to(:bulk) }
    it { is_expected.to delegate_method(:ratings).to(:bulk) }
    it { is_expected.to delegate_method(:account).to(:bulk) }
  end

  describe 'validations' do
    describe 'item validity' do
      subject { described_class.new(bulk: bulk) }

      before :each do
        allow(bulk).to receive(:ratings).and_return(ratings)
        allow(bulk).to receive(:items).and_return([])
      end
      context 'without ratings' do
        let(:ratings) { [] }

        it { is_expected.to validate_presence_of(:subject_id) }
      end

      context 'with ratings' do
        let(:ratings) { [instance_double(Rating), instance_double(Rating)]}

        describe 'evaluations' do
          it 'validates evaluations' do
            subject.subject_id = "21"

            expect(subject.evaluations.first).to receive(:valid?).and_return(true)
            expect(subject.evaluations.second).to receive(:valid?).and_return(true)

            expect(subject.valid?).to be_truthy
            expect(subject.errors[:evaluations]).not_to be_present
          end

          it 'is not valid if an evaluation is invalid' do
            allow(subject.evaluations.first).to receive(:valid?).and_return(false)
            allow(subject.evaluations.second).to receive(:valid?).and_return(true)

            expect(subject.valid?).to be_falsey
            expect(subject.errors[:evaluations]).to be_present
          end
        end
      end
    end

    describe 'subject uniqueness' do
      let(:exercise) { FactoryGirl.build(:exercise) }
      let(:bulk) { SubmissionBulk::Bulk.new(exercise: exercise) }

      let(:subject_1) { instance_double(TermRegistration, id: 1) }
      let(:subject_2) { instance_double(TermRegistration, id: 2) }
      let(:subject_3) { instance_double(TermRegistration, id: 3) }

      let(:items) { [instance_double(described_class, subject: subject_1), instance_double(described_class, subject: subject_2), subject] }

      subject { described_class.new(bulk: bulk) }

      before :each do
        bulk.items = items
      end

      it 'adds an error to :subject if subject is not unique' do
        subject.subject = subject_2
        subject.subject_id = subject.subject.id
        subject.validate

        expect(subject.errors[:subject]).not_to be_blank
        expect(subject.errors[:subject_id]).not_to be_blank
      end

      it 'does not add an error to :subject if subject is unique' do
        subject.subject = subject_3
        subject.subject_id = subject.subject.id
        subject.validate

        expect(subject.errors[:subject]).to be_blank
        expect(subject.errors[:subject_id]).to be_blank
      end
    end
  end

  describe 'methods' do
    describe '#subject_id?' do
      it 'returns true if subject_id is present' do
        subject.subject_id = 42
        expect(subject.subject_id?).to be_truthy

        subject.subject_id = "21"
        expect(subject.subject_id?).to be_truthy
      end

      it 'returns false if subject_id is blank' do
        subject.subject_id = nil
        expect(subject.subject_id?).to be_falsey

        subject.subject_id = ""
        expect(subject.subject_id?).to be_falsey
      end
    end

    describe '#subject?' do
      let(:term_registration_subject) { instance_double(TermRegistration) }

      it 'returns true if subject is present' do
        subject.subject = term_registration_subject
        expect(subject.subject?).to be_truthy
      end

      it 'returns false if subject is blank' do
        subject.subject = nil
        expect(subject.subject?).to be_falsey
      end
    end

    describe '#submission?' do
      let(:submission) { instance_double(Submission) }

      it 'returns true if subject is present' do
        subject.submission = submission
        expect(subject.submission?).to be_truthy
      end

      it 'returns false if subject is blank' do
        subject.submission = nil
        expect(subject.submission?).to be_falsey
      end
    end

    describe '#evaluations' do
      let(:ratings) { [instance_double(Rating), instance_double(Rating), instance_double(Rating)] }

      subject { described_class.new(bulk: bulk) }

      it 'returns an array of SubmissionBulk::Evaluations with correct attributes set' do
        allow(bulk).to receive(:ratings).and_return(ratings)

        subject.evaluations.zip(ratings) do |evaluation_and_rating|
          evaluation, rating = evaluation_and_rating

          expect(evaluation).to be_a(SubmissionBulk::Evaluation)
          expect(evaluation.item).to eq(subject)
          expect(evaluation.rating).to eq(rating)
        end
      end

      it 'returns an empty array if bulk.ratings is empty' do
        allow(bulk).to receive(:ratings).and_return([])

        expect(subject.evaluations).to eq([])
      end
    end

    describe '#evaluations_attributes=' do
      subject { described_class.new(bulk: bulk) }

      let(:evaluation_attributes_1) { {rating_id: "21", value: "0"} }
      let(:evaluation_attributes_2) { {rating_id: "23", value: "2"} }

      let(:evaluation_1) { instance_double(SubmissionBulk::Evaluation) }
      let(:evaluation_2) { instance_double(SubmissionBulk::Evaluation) }

      it 'builds evaluations based on given attributes' do
        expect(SubmissionBulk::Evaluation).to receive(:new).with(evaluation_attributes_1.merge(item: subject)).and_return(evaluation_1)
        expect(SubmissionBulk::Evaluation).to receive(:new).with(evaluation_attributes_2.merge(item: subject)).and_return(evaluation_2)

        subject.evaluations_attributes = {"1" => evaluation_attributes_1, "2" => evaluation_attributes_2}

        expect(subject.evaluations).to match_array([evaluation_1, evaluation_2])
      end
    end

    describe '#save' do
      let(:ratings) { FactoryGirl.create_list(:fixed_points_deduction_rating, 3, exercise: exercise) }
      let(:term) { FactoryGirl.create(:term) }
      let(:exercise) { FactoryGirl.create(:exercise) }
      let(:account) { FactoryGirl.create(:account, :admin) }
      let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
      let(:submission_evaluation) { submission.submission_evaluation }

      subject { described_class.new(bulk: bulk, subject: submission_subject) }

      before :each do
        allow(bulk).to receive(:ratings).and_return(ratings)

        subject.evaluations.each do |evaluation|
          allow(evaluation).to receive(:save)
        end
      end

      shared_examples "saving behaviour" do
        it 'creates a submission if it is not present' do
          expect(SubmissionCreationService).to receive(:new_staff_submission).with(account, submission_subject, exercise).and_call_original

          subject.submission = nil

          expect do
            subject.save
          end.to change(Submission, :count).by(1)
        end

        it 'does not create a submission if it is present' do
          expect(SubmissionCreationService).not_to receive(:new_staff_submission)

          subject.submission = submission

          expect do
            subject.save
          end.not_to change(Submission, :count)
        end

        it 'calls #save on evaluations' do
          subject.evaluations.each do |evaluation|
            expect(evaluation).to receive(:save)
          end

          subject.save
        end

        it 'updates submission_evaluation' do
          subject.submission = submission

          expect(submission_evaluation.evaluated_at).to be_blank
          expect(submission_evaluation.evaluator).to be_blank

          subject.save

          submission_evaluation.reload
          expect(submission_evaluation.evaluated_at).not_to be_blank
          expect(submission_evaluation.evaluator).to eq(account)
        end
      end

      context 'solitary exercise' do
        let(:exercise) { FactoryGirl.create(:exercise, :solitary_exercise, term: term) }
        let(:submission_subject) { FactoryGirl.create(:term_registration, :student, term: term)}

        it_behaves_like "saving behaviour"
      end

      context 'group exercise' do
        let(:exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }
        let(:submission_subject) { FactoryGirl.create(:student_group, term: term)}

        it_behaves_like "saving behaviour"
      end
    end

    describe '#evaluation_for_rating' do
      let(:exercise) { FactoryGirl.create(:exercise) }
      let(:rating_group) { FactoryGirl.create(:rating_group, exercise: exercise) }
      let!(:ratings) { FactoryGirl.create_list(:fixed_points_deduction_rating, 3, rating_group: rating_group) }
      let!(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
      let(:rating) { ratings.second }
      let(:other_rating) { FactoryGirl.create(:fixed_points_deduction_rating) }
      let(:evaluation) { rating.evaluations.for_submission(submission).first }

      subject { described_class.new(submission: submission) }

      it 'returns the requested evaluation' do
        expect(subject.evaluation_for_rating(rating)).to eq(evaluation)
      end

      it 'returns nil if rating does not belong to the exercise' do
        expect(subject.evaluation_for_rating(other_rating)).to be_nil
      end
    end

    describe '#values?' do
      let(:ratings) { [instance_double(Rating), instance_double(Rating), instance_double(Rating)] }

      subject { described_class.new(bulk: bulk) }

      before :each do
        allow(bulk).to receive(:ratings).and_return(ratings)
      end

      it 'returns true if subject_id is set' do
        subject.subject_id = "42"
        allow(subject.evaluations.first).to receive(:value?).and_return(false)
        allow(subject.evaluations.second).to receive(:value?).and_return(false)
        allow(subject.evaluations.third).to receive(:value?).and_return(false)

        expect(subject.values?).to be_truthy
      end

      it 'returns true if an evaluation has a value' do
        subject.subject_id = nil
        allow(subject.evaluations.first).to receive(:value?).and_return(false)
        allow(subject.evaluations.second).to receive(:value?).and_return(true)
        allow(subject.evaluations.third).to receive(:value?).and_return(false)

        expect(subject.values?).to be_truthy
      end

      it 'returns false if neither subject_id is present nor any evaluations has a value' do
        subject.subject_id = ""
        allow(subject.evaluations.first).to receive(:value?).and_return(false)
        allow(subject.evaluations.second).to receive(:value?).and_return(false)
        allow(subject.evaluations.third).to receive(:value?).and_return(false)

        expect(subject.values?).to be_falsey
      end
    end
  end
end
