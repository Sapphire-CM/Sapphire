require 'rails_helper'

RSpec.describe TermCopyService do

  describe 'initialization' do
    let(:term) { FactoryBot.build(:term) }
    let(:course) { term.course }
    let(:source_term) { FactoryBot.build(:term, course: course) }

    it 'assigns term, source term' do
      subject = described_class.new(term, source_term)

      expect(subject.term).to eq(term)
      expect(subject.source_term).to eq(source_term)
    end

    it 'assigns options' do
      subject = described_class.new(term, source_term, lecturers: true, exercises: true, grading_scale: true)

      expect(subject.copy_lecturers).to be_truthy
      expect(subject.copy_exercises).to be_truthy
      expect(subject.copy_grading_scale).to be_truthy
    end

    it 'initializes options with default values' do
      subject = described_class.new(term, source_term)

      expect(subject.copy_lecturers).to be_falsey
      expect(subject.copy_exercises).to be_falsey
      expect(subject.copy_grading_scale).to be_falsey
    end

    it 'does not raise if invalid options are passed' do
      expect do
        described_class.new(term, source_term, {fourty_two: 42})
      end.not_to raise_error
    end
  end

  describe 'methods' do
    describe '#perform!' do
      let(:term) { FactoryBot.create(:term) }
      let(:source_term) { FactoryBot.create(:term, course: term.course) }

      context 'with exercises' do
        let!(:source_exercises) { FactoryBot.create_list(:exercise, 2, :with_ratings, term: source_term) }

        let(:exercise_attributes) { %I(title description deadline late_deadline enable_max_total_points enable_student_uploads max_total_points group_submission) }
        let(:rating_group_attributes) { %I(title title points description global min_points max_points enable_range_points) }
        let(:rating_attributes) { %I(title value description type max_value min_value row_order multiplication_factor automated_checker_identifier bulk) }

        it 'copies exercises if options include exercises' do
          subject = described_class.new(term, source_term, exercises: true)

          expect do
            subject.perform!
          end.to change(term.exercises, :count).by(2)

          source_term.exercises.each do |source_exercise|
            destination_exercise = term.exercises.find_by!(title: source_exercise.title)
            exercise_attributes.each { |attribute| expect(destination_exercise.send(attribute)).to eq(source_exercise.send(attribute)) }

            source_exercise.rating_groups.each do |source_rating_group|
              destination_rating_group = destination_exercise.rating_groups.find_by!(title: source_rating_group.title)

              rating_group_attributes.each { |attribute| expect(destination_rating_group.send(attribute)).to eq(source_rating_group.send(attribute)) }

              source_rating_group.ratings.each do |source_rating|
                destination_rating = destination_rating_group.ratings.find_by!(title: source_rating.title)

                rating_attributes.each { |attribute| expect(destination_rating.send(attribute)).to eq(source_rating.send(attribute)) }
              end
            end
          end
        end

        it 'does not copy exercises if options do not include exercises' do
          subject = described_class.new(term, source_term, exercises: false)

          expect do
            subject.perform!
          end.not_to change(term.exercises, :count)
        end
      end

      context 'with lecturers' do
        let!(:source_lecturers) { FactoryBot.create_list(:term_registration, 3, :lecturer, term: source_term) }

        let(:term_attributes) do
          {
            only: [],
            include: {
              term_registrations: {
                only: %I(account_id role)
              }
            }
          }
        end

        it 'copys lecturers if options include lecturers' do
          subject = described_class.new(term, source_term, lecturers: true)

          expect do
            subject.perform!
          end.to change(term.term_registrations, :count).by(3)

          expect(term.as_json(term_attributes)["term_registrations"]).to match_array(source_term.as_json(term_attributes)["term_registrations"])
        end

        it 'does not copy lecturers if options do not include lecturers' do
          subject = described_class.new(term, source_term, lecturers: false)

          expect do
            subject.perform!
          end.not_to change(term.term_registrations, :count)
        end
      end

      context 'with grading scales' do
        before :each do
          source_term.grading_scales.order(:grade).each do |grading_scale|
            next if grading_scale.not_graded?

            grade = grading_scale.grade.to_i

            min_points = if grade == 5
              0
            else
              100 + 100 * (5 - grade)
            end

            max_points = 100 + 100 * (6 - grade) - 1

            grading_scale.update(min_points: min_points, max_points: max_points)
          end
        end

        let(:term_attributes) do
          {
            only: [],
            include: {
              grading_scales: {
                only: %I(grade not_graded positive min_points max_points)
              }
            }
          }
        end

        def extract_attributes(term)
          term.as_json(term_attributes)["grading_scales"].sort_by { |grading_scale| grading_scale["grade"] }
        end

        it 'assigns the grading scale attributes if options include grading_scale' do
          subject = described_class.new(term, source_term, grading_scale: true)
          subject.perform!

          expect(extract_attributes(term)).to match(extract_attributes(source_term))
        end

        it 'does not assign the grading scale attributes if options do not include grading_scale' do
          subject = described_class.new(term, source_term, grading_scale: false)
          subject.perform!

          expect(extract_attributes(term)).not_to match(extract_attributes(source_term))
        end
      end
    end
  end
end