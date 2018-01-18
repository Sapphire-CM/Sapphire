require "rails_helper"

RSpec.describe StudentGroup do
  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:keyword).of_type(:string) }
    it { is_expected.to have_db_column(:topic).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:tutorial_group) }
    it { is_expected.to have_one(:term).through(:tutorial_group) }
    it { is_expected.to have_many(:term_registrations).dependent(:nullify) }
    it { is_expected.to have_many(:students).through(:term_registrations) }
    it { is_expected.to have_many(:submissions).dependent(:nullify) }
    it { is_expected.to have_many(:submission_evaluations).through(:submissions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:tutorial_group_id) }
  end

  describe 'callbacks' do
    describe 'moving students' do
      let(:term) { FactoryGirl.create(:term) }
      let(:other_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let(:other_student_group) { FactoryGirl.create(:student_group, term: term, tutorial_group: other_tutorial_group) }
      let!(:term_registrations_of_other_student_group) { FactoryGirl.create_list(:term_registration, 3, :student, term: term, tutorial_group: other_tutorial_group, student_group: other_student_group) }

      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

      subject { FactoryGirl.create(:student_group, tutorial_group: tutorial_group, term: term) }

      it 'sets the tutorial group of moved term registrations' do
        term_registrations_of_other_student_group.each do |term_registration|
          expect(term_registration.tutorial_group).to eq(other_tutorial_group)
        end

        subject.term_registrations = term_registrations_of_other_student_group
        subject.save

        subject.term_registrations.each do |term_registration|
          term_registration.reload
          expect(term_registration.tutorial_group).to eq(tutorial_group)
        end
      end
    end
  end

  describe 'scoping' do
    describe '.for_term' do
      let(:term) { FactoryGirl.create(:term) }
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:student_groups_for_term) { FactoryGirl.create_list(:student_group, 3, term: term, tutorial_group: tutorial_group) }
      let!(:other_student_groups) { FactoryGirl.create_list(:student_group, 3) }

      it 'only returns the student groups for the given term' do
        expect(described_class.for_term(term)).to match_array(student_groups_for_term)
      end
    end

    describe '.for_tutorial_group' do
      let(:term) { FactoryGirl.create(:term) }
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let(:other_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:student_groups_for_tutorial_group) { FactoryGirl.create_list(:student_group, 3, term: term, tutorial_group: tutorial_group) }
      let!(:other_student_groups) { FactoryGirl.create_list(:student_group, 3, term: term, tutorial_group: other_tutorial_group) }

      it 'only returns the student groups for the given tutorial group' do
        expect(described_class.for_tutorial_group(tutorial_group)).to match_array(student_groups_for_tutorial_group)
      end
    end

    describe '.for_account' do
      let(:account) { FactoryGirl.create(:account) }
      let!(:student_groups_for_account) { FactoryGirl.create_list(:student_group_for_student, 3, student: account) }
      let!(:other_student_groups) { FactoryGirl.create_list(:student_group_for_student, 3) }

      it 'only returns student groups associated with the given account' do
        expect(described_class.for_account(account)).to match_array(student_groups_for_account)
      end
    end
  end

  describe 'methods' do
    pending '#update_points!'
  end


end