require 'rails_helper'

RSpec.describe GradingOverview do
  let(:term) { FactoryGirl.create(:term, :with_tutorial_groups) }
  let(:grading_scales) { term.grading_scales }
  let(:tutorial_groups) { term.tutorial_groups }

  subject { described_class.new(term, grading_scales, tutorial_groups) }

  describe 'initialization' do
    it 'assigns overall_grading_scale_service' do
      expect(subject.overall_grading_scale_service).to be_a(GradingScaleService)
    end
  end

  describe 'methods' do
    context 'without grades' do
      describe '#term' do
        it 'returns term' do
          expect(subject.term).to eq(term)
        end
      end

      describe '#tutorial_groups' do
        it 'returns tutorial_groups' do
          expect(subject.tutorial_groups).to eq(tutorial_groups)
        end
      end

      describe '#grading_scales' do
        it 'returns grading_scales' do
          expect(subject.grading_scales).to eq(grading_scales)
        end
      end
    end

    context 'concerning all students' do
      let!(:mocked_overall_grading_scale_service) { double(GradingScaleService.new(term)) }

      before :each do
        allow(GradingScaleService).to receive(:new).and_return(mocked_overall_grading_scale_service)
      end

      describe '#graded_count' do
        it 'returns the overall students count' do
          expect(mocked_overall_grading_scale_service).to receive(:graded_count).and_return(42)

          expect(subject.graded_count).to eq(42)
        end
      end

      describe '#ungraded_count' do
        it 'returns the overall ungraded_count' do
          expect(mocked_overall_grading_scale_service).to receive(:ungraded_count).and_return(23)

          expect(subject.ungraded_count).to eq(23)
        end
      end

      describe '#students_count' do
        it 'returns the overall ungraded_count' do
          expect(mocked_overall_grading_scale_service).to receive(:graded_count).and_return(35)
          expect(mocked_overall_grading_scale_service).to receive(:ungraded_count).and_return(3)

          expect(subject.students_count).to eq(38)
        end
      end

      describe '#count_for_grading_scale' do
        let(:grading_scale) { grading_scales.first }

        it 'returns the overall count for the grading scale' do
          expect(mocked_overall_grading_scale_service).to receive(:count_for).with(grading_scale).and_return(37)
          expect(subject.count_for_grading_scale(grading_scale)).to eq(37)
        end
      end

      describe '#percent_for_grading_scale' do
        let(:grading_scale) { grading_scales.first }

        it 'returns the overall percent for the grading scale' do
          expect(mocked_overall_grading_scale_service).to receive(:percent_for).with(grading_scale).and_return(12)
          expect(subject.percent_for_grading_scale(grading_scale)).to eq(12)
        end
      end
    end

    context 'concerning students of a tutorial group' do
      let(:first_tutorial_group) { tutorial_groups.first }
      let(:second_tutorial_group) { tutorial_groups.second }
      let!(:students_of_first_tutorial_group) { FactoryGirl.create_list(:term_registration, 3, :student, term: term, tutorial_group: first_tutorial_group) }
      let!(:students_of_second_tutorial_group) { FactoryGirl.create_list(:term_registration, 2, :student, term: term, tutorial_group: second_tutorial_group) }

      let(:mocked_overall_grading_scale_service) { double }
      let(:mocked_first_grading_scale_service) { double("First Grading Scale Service") }
      let(:mocked_second_grading_scale_service) { double("Second Grading Scale Service") }

      let(:grading_scale) { grading_scales.third }

      before :each do
        allow(GradingScaleService).to receive(:new).with(term).and_return(mocked_overall_grading_scale_service)
        allow(GradingScaleService).to receive(:new).with(term, first_tutorial_group.student_term_registrations).and_return(mocked_first_grading_scale_service)
        allow(GradingScaleService).to receive(:new).with(term, second_tutorial_group.student_term_registrations).and_return(mocked_second_grading_scale_service)
      end

      describe '#count_for_tutorial_group_and_grading_scale' do
        it 'calls the correct grading scale service' do
          expect(mocked_first_grading_scale_service).to receive(:count_for).with(grading_scale).and_return(43)
          expect(mocked_second_grading_scale_service).not_to receive(:count_for)

          expect(subject.count_for_tutorial_group_and_grading_scale(first_tutorial_group, grading_scale)).to eq(43)
        end
      end

      describe '#student_count_for_tutorial_group' do
        it 'calls the correct grading scale service' do
          expect(mocked_first_grading_scale_service).not_to receive(:term_registrations)
          expect(mocked_second_grading_scale_service).to receive(:term_registrations).and_return(students_of_second_tutorial_group)

          expect(subject.student_count_for_tutorial_group(second_tutorial_group)).to eq(2)
        end
      end
    end
  end
end