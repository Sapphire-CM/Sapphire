require 'rails_helper'

RSpec.describe GradingReview::TermReview do
  let(:term) { FactoryGirl.create(:term) }
  let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }

  describe 'initialization' do
    it 'sets eager_load_evaluations to falsey' do
      expect(subject.eager_load_evaluations).to be_falsey
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:student).to(:term_registration).as(:account) }
    it { is_expected.to delegate_method(:term).to(:term_registration) }
    it { is_expected.to delegate_method(:points).to(:term_registration) }
    it { is_expected.to delegate_method(:tutorial_group).to(:term_registration) }

    it { is_expected.to delegate_method(:achievable_points).to(:term) }

    it { is_expected.to delegate_method(:all_results_published?).to(:tutorial_group) }
  end

  describe 'methods' do
    subject { described_class.new(term_registration: term_registration) }

    describe '.find_with_term_and_term_registration_id' do
      let(:term_registration) { FactoryGirl.create(:term_registration) }
      let(:term) { term_registration.term }

      it 'returns a grading review and sets student' do
        subject = described_class.find_with_term_and_term_registration_id(term, term_registration.id)

        expect(subject.term_registration).to eq(term_registration)
      end

      %I(lecturer tutor).each do |role|
        context do
          let(:term_registration) { FactoryGirl.create(:term_registration, role) }

          it "raises ActiveRecord::RecordNotFound if term_registration belongs to a #{role}" do
            expect do
              described_class.find_with_term_and_term_registration_id(term, term_registration.id)
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      it 'raises ActiveRecord::RecordNotFound if student id is unknown' do
        expect do
          described_class.find_with_term_and_term_registration_id(term, 42)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '.find_with_term_and_account' do
      let(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
      let(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term) }
      let(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term) }

      let(:term) { FactoryGirl.create(:term) }

      it 'returns a grading review and sets student' do
        subject = described_class.find_with_term_and_account(term, student_term_registration.account)

        expect(subject.term_registration).to eq(student_term_registration)
      end

      it 'raises ActiveRecord::RecordNotFound if account is a tutor' do
        expect do
          described_class.find_with_term_and_account(term, tutor_term_registration.account)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises ActiveRecord::RecordNotFound if account is a lecturer' do
        expect do
          described_class.find_with_term_and_account(term, lecturer_term_registration.account)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#grading_scale' do
      it 'returns a new GradingScaleService based on given term' do
        service = subject.grading_scale_service
        expect(service).to be_a(GradingScaleService)
        expect(service.term).to eq(term)
      end
    end

    describe '#submission_reviews' do
      let(:exercises) { FactoryGirl.create_list(:exercise, 3, term: term) }

      let(:submissions) { exercises.map { |exercise| FactoryGirl.create(:submission, exercise: exercise) } }
      let!(:exercise_registrations) { submissions.map { |submission| FactoryGirl.create(:exercise_registration, term_registration: term_registration, submission: submission, exercise: submission.exercise) }  }

      it 'returns a collection of GradingReview::SubmissionReview objects' do
        subject.submission_reviews.each do |submission_review|
          expect(submission_review).to be_a(GradingReview::SubmissionReview)
        end
      end

      it 'returns a collection based on exercise registrations' do
        expect(subject.submission_reviews.map(&:exercise_registration)).to match(exercise_registrations)
      end

      it 'sets the result publication status' do
        exercises.second.result_publications.each(&:publish!)
        reviews = subject.submission_reviews

        expect(ResultPublication).not_to receive(:for)

        expect(reviews.first).not_to be_published
        expect(reviews.second).to be_published
        expect(reviews.third).not_to be_published
      end

      it 'queries for records only once' do
        expect(term_registration).to receive(:exercise_registrations).once.and_call_original

        subject.submission_reviews
        subject.submission_reviews
      end

      context "with exercises containing ratings" do
        let(:exercises) { FactoryGirl.create_list(:exercise, 3, :with_ratings, term: term) }

        it 'eager loads evaluations if requested' do
          subject.eager_load_evaluations!

          subject.submission_reviews.each do |review|
            expect(review.submission_evaluation.association(:evaluations)).to be_loaded
            expect(review.submission_evaluation.evaluations.first.association(:rating)).to be_loaded
            expect(review.submission_evaluation.evaluations.first.association(:evaluation_group)).to be_loaded
            expect(review.submission_evaluation.evaluations.first.evaluation_group.association(:rating_group)).to be_loaded
          end
        end

        it 'does not eager load evaluations unless requested' do
          subject.submission_reviews.each do |review|
            expect(review.submission_evaluation.association(:evaluations)).not_to be_loaded
          end
        end
      end
    end

    describe '#eager_load_evaluations!' do
      it 'sets eager_load_evaluations to true' do
        subject.eager_load_evaluations!

        expect(subject.eager_load_evaluations).to be_truthy
      end
    end

    describe '#grade' do
      it 'returns the grade given by the grading scale service' do
        expect(subject.grading_scale_service).to receive(:grade_for).with(term_registration).and_return(42)

        expect(subject.grade).to eq(42)
      end
    end

    describe '#published_points' do
      let(:exercises) { FactoryGirl.create_list(:exercise, 3, term: term) }
      let(:submissions) { exercises.map { |exercise| FactoryGirl.create(:submission, exercise: exercise) } }
      let!(:exercise_registrations) { submissions.map { |submission| FactoryGirl.create(:exercise_registration, term_registration: term_registration, submission: submission, exercise: submission.exercise) }  }

      it "sums up the points of published submissions" do
        exercises.second.result_publications.each(&:publish!)

        exercise_registrations.first.update(points: 15)
        exercise_registrations.second.update(points: 42)
        exercise_registrations.third.update(points: 31)

        expect(subject.published_points).to eq(42)
      end

      it 'excludes inactive submissions' do
        exercises.flat_map(&:result_publications).each(&:publish!)

        submissions.second.update(active: false)

        exercise_registrations.first.update(points: 15)
        exercise_registrations.second.update(points: 42)
        exercise_registrations.third.update(points: 31)

        expect(subject.published_points).to eq(46)
      end
    end

  end
end