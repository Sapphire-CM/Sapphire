require 'rails_helper'

RSpec.describe GradingScale::Bulk do

  describe 'initialization' do
    let(:term) { double(Term) }
    let(:grading_scale_attributes) { [] }

    it 'accepts attributes as options' do
      subject = described_class.new({term: term, grading_scale_attributes: grading_scale_attributes })

      expect(subject.term).to eq(term)
      expect(subject.grading_scale_attributes).to eq(grading_scale_attributes)
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:grading_scales).to(:term) }
  end

  describe 'methods' do
    let(:term) { FactoryGirl.create(:term) }

    subject { described_class.new(term: term) }

    describe '#save' do
      let(:new_max_points) { 120 }
      let(:grading_scale_attributes_array) do
        term.grading_scales.map do |grading_scale|
          {
            id: grading_scale.id,
            min_points: grading_scale.min_points,
            max_points: (grading_scale.grade == "1" ? new_max_points : grading_scale.max_points)
          }
        end
      end

      let(:grading_scale_attributes_hash) do
        term.grading_scales.map.with_index do |grading_scale, idx|
          [
            idx,
            {
              id: grading_scale.id,
              min_points: grading_scale.min_points,
              max_points: (grading_scale.grade == "1" ? new_max_points : grading_scale.max_points)
            }
          ]
        end.to_h
      end

      it 'updates grading scales according to the grading_scale_attributes array' do
        subject.grading_scale_attributes = grading_scale_attributes_array
        subject.save

        expect(term.grading_scales.find_by(grade: "1").max_points).to eq(new_max_points)
      end

      it 'updates grading scales according to the grading_scale_attributes array' do
        subject.grading_scale_attributes = grading_scale_attributes_hash
        subject.save

        expect(term.grading_scales.find_by(grade: "1").max_points).to eq(new_max_points)
      end

      it 'returns false if grading scale cannot be found' do
        subject.grading_scale_attributes = [ {id: -1, min_points: 0, max_points: 10} ]

        expect(subject.save).to be_falsey
      end

      it 'returns false if grading scale is invalid' do
        grading_scale = term.grading_scales.last
        subject.grading_scale_attributes = [
          {
            id: grading_scale.id,
            min_points: grading_scale.max_points,
            max_points: grading_scale.min_points
          }
        ]

        expect(subject.save).to be_falsey
      end
    end

    describe '#errors' do
      let(:errors_obj) { double }

      it 'collects all errors from the grading_scales' do
        term.grading_scales.each do |grading_scale|
          expect(grading_scale).to receive(:errors).and_return(errors_obj)
        end

        subject.errors.each do |error|
          expect(error).to eq(errors_obj)
        end
      end
    end
  end
end