require 'rails_helper'

describe Term do
  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:row_order).of_type(:integer) }
    it { is_expected.to have_db_column(:points).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:status).of_type(:integer).with_options(default: 0) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to have_many(:term_registrations).dependent(:destroy) }
    it { is_expected.to have_many(:exercises).dependent(:destroy) }
    it { is_expected.to have_many(:tutorial_groups).dependent(:destroy) }
    it { is_expected.to have_many(:term_registrations).dependent(:destroy) }
    it { is_expected.to have_many(:events).dependent(:destroy) }
    it { is_expected.to have_many(:imports).dependent(:destroy) }
    it { is_expected.to have_many(:exports).dependent(:destroy) }

    it { is_expected.to have_many(:submissions).through(:exercises) }
    it { is_expected.to have_many(:student_groups).through(:tutorial_groups) }
    it { is_expected.to have_many(:exercise_registrations).through(:term_registrations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:course_id) }
  end

  describe 'attributes' do
    it { is_expected.to define_enum_for(:status).with([:ready, :preparing]) }
  end

  describe 'methods' do
    pending '#associated_with?'
    pending '#update_points!'
    pending '#achievable_points'
    pending '#lecturers'
    pending '#tutors'
    pending '#students'
    pending '#group_submissions?'
    pending '#participated?'
    pending '#valid_grading_scales?'
  end

  describe 'callbacks' do
    describe 'grading_scales' do
      let(:course) { FactoryGirl.create(:course) }
      subject { FactoryGirl.create(:term, course: course, title: 'new term') }

      it 'creates all grading_scales with after_create' do
        expect(subject.grading_scales.length).to eq(6)
        expect(subject.grading_scales.where(not_graded: true).length).to eq(1)
        expect(subject.grading_scales.where(positive: false, not_graded: false).length).to eq(1)
        expect(subject.grading_scales.where(positive: true, not_graded: false).length).to eq(4)
        expect(subject.grading_scales.positives.length).to eq(4)
        expect(subject.grading_scales.pluck(:grade)).to match_array(%w(1 2 3 4 5 0))
        expect(subject.valid_grading_scales?).to eq(true)
      end
    end
  end

  context 'ordinary account' do
    let(:account) { FactoryGirl.create(:account) }

    it 'scopes all terms associated with an account' do
      terms = FactoryGirl.create_list(:term, 5)

      t = terms[0]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:term_registration, :tutor, account: account, term: t, tutorial_group: tg)

      t = terms[1]
      FactoryGirl.create(:term_registration, :lecturer, account: account, term: t)

      t = terms[2]
      tg = FactoryGirl.create(:tutorial_group, term: t)
      FactoryGirl.create(:term_registration, :student, account: account, term: t, tutorial_group: tg)

      expect(Term.associated_with(account).sort_by(&:id)).to eq(terms.first(3))
    end

    it 'is able to determine whether a lecturer account is associated with this term' do
      term = FactoryGirl.create(:term)

      expect(term).not_to be_associated_with(account)
      FactoryGirl.create(:term_registration, :lecturer, account: account, term: term)

      expect(term).to be_associated_with(account)
    end

    %I(tutor student).each do |role|
      it "is able to determine whether a #{role} account is associated with this term" do
        term = FactoryGirl.create(:term)

        expect(term).not_to be_associated_with(account)
        tg = FactoryGirl.create(:tutorial_group, term: term)
        FactoryGirl.create(:term_registration, role, account: account, term: term, tutorial_group: tg)

        expect(term).to be_associated_with(account)
      end
    end
  end
end
