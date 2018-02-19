require 'rails_helper'

RSpec.shared_examples 'an evaluation' do
  describe 'associations' do
    it { is_expected.to belong_to(:evaluation_group).touch(true) }
    it { is_expected.to belong_to(:rating) }

    it { is_expected.to have_one(:submission_evaluation).through(:evaluation_group) }
    it { is_expected.to have_one(:student_group).through(:submission_evaluation) }
    it { is_expected.to have_one(:submission).through(:submission_evaluation) }
    it { is_expected.to have_one(:rating_group).through(:evaluation_group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:evaluation_group) }
    it { is_expected.to validate_presence_of(:rating) }

    pending 'evaluation_type'
  end

  describe 'callbacks' do
    describe '#update_result!' do
      pending "is called after create"
      pending "is called after update"
    end
    describe '#update_needs_result!' do
      pending "is called after update"
      pending "is called after destroy"
    end
  end

  describe 'methods' do
    subject { described_class.new }

    it { is_expected.to respond_to(:points) }
    it { is_expected.to respond_to(:percent) }
    it { is_expected.to respond_to(:show_to_students?) }

    describe '#show_to_students?' do
      it "does not raise an error when called" do
        expect do
          subject.show_to_students?
        end.not_to raise_error
      end
    end
  end
end
