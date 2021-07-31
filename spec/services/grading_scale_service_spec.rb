require 'rails_helper'

RSpec.describe GradingScaleService, type: :model do
  let!(:account) { FactoryBot.create :account }
  let!(:term) { FactoryBot.create :term }
  let!(:exercise) { FactoryBot.create :exercise, :with_ratings, term: term }
  let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: account, points: 40) }

  context 'gives the correct grade for term_registration' do
    def expect_grade_to_be(grade)
      grading_scale_service = described_class.new(term)
      result = grading_scale_service.grade_for(term_registration)
      expect(result).to eq(grade)
    end

    def show_grading_scale
      term.grading_scales.ordered.each do |gs|
        puts "#{gs.grade}: #{'%3d'.format gs.min_points} - #{'%3d'.format gs.max_points}"
      end
    end

    it 'does not give a grade for no submissions' do
      term_registration.reload
      expect_grade_to_be '0'
    end

    context 'with a submission' do
      before :each do
        SubmissionCreationService.new_student_submission(account, exercise).save
        term_registration.reload
      end

      {
        -1 => '5',
        0 => '5',
        1 => '5',
        49 => '5',
        50 => '5',
        51 => '4',
        52 => '4',
        59 => '4',
        60 => '4',
        61 => '3',
        62 => '3',
        83 => '3',
        84 => '3',
        85 => '2',
        86 => '2',
        89 => '2',
        90 => '2',
        91 => '1',
        92 => '1',
        100 => '1',
        101 => '1'
      }.each do |points, grade|
        it "gives the correct grade #{grade} for #{points} points" do
          term_registration.update_points!
          term_registration.update! points: points
          expect_grade_to_be grade
        end
      end

      it 'gives negative grade if exercise required minimum points' do
        term_registration.update! points: 55

        perform_enqueued_jobs do
          exercise.update! enable_min_required_points: true, min_required_points: 54
        end

        term_registration.reload

        expect_grade_to_be '5'
      end
    end
  end

  describe 'methods' do
    describe '#distribution' do
    end
  end
end
