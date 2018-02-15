require 'rails_helper'

RSpec.describe TermRegistration do

  describe 'db columns' do
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:positive_grade).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:receives_grade).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:role).of_type(:integer).with_options(default: 0) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:welcomed_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:term) }
    it { is_expected.to belong_to(:tutorial_group) }
    it { is_expected.to belong_to(:student_group) }

    it { is_expected.to have_many(:exercise_registrations).dependent(:destroy) }
    it { is_expected.to have_many(:submissions).through(:exercise_registrations) }
    it { is_expected.to have_many(:exercises).through(:exercise_registrations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :account }
    it { is_expected.to validate_presence_of :term }

    # this currently failes because of https://github.com/thoughtbot/shoulda-matchers/issues/535
    # it { is_expected.to validate_uniqueness_of(:account).scoped_to(:term_id)}
  end

  describe 'methods' do
    describe '#negative_grade' do
      it 'returns the inverse of positive_grade' do
        subject.positive_grade = true
        expect(subject.negative_grade?).to be_falsey

        subject.positive_grade = false
        expect(subject.negative_grade?).to be_truthy
      end
    end

    describe 'welcomed?' do
      it 'returns true if welcomed_at is present' do
        subject.welcomed_at = 2.days.ago

        expect(subject).to be_welcomed
      end

      it 'returns false if welcomed_at is blank' do
        subject.welcomed_at = nil

        expect(subject).not_to be_welcomed
      end
    end
  end

  describe 'scopes' do
    context 'role based' do
      let!(:lecturer_registrations) { FactoryGirl.create_list :term_registration, 3, :lecturer }
      let!(:tutor_registrations) { FactoryGirl.create_list :term_registration, 5, :tutor }
      let!(:student_registrations) { FactoryGirl.create_list :term_registration, 7, :student }

      it 'scopes lecturers' do
        expect(described_class.lecturer).to eq(described_class.lecturers)
        expect(described_class.lecturer).to match_array(lecturer_registrations)
      end

      it 'scopes tutors' do
        expect(described_class.tutor).to eq(described_class.tutors)
        expect(described_class.tutor).to match_array(tutor_registrations)
      end

      it 'scopes students' do
        expect(described_class.student).to eq(described_class.students)
        expect(described_class.student).to match_array(student_registrations)
      end

      it 'scopes staff' do
        expect(described_class.staff).to match_array(lecturer_registrations + tutor_registrations)
      end

      it 'ordered by matriculation number' do
        expect(described_class.students.ordered_by_matriculation_number).to eq(described_class.students.joins(:account).order { account.matriculation_number.asc })
      end
    end

    context 'welcoming users' do
      let!(:welcomed_term_registrations) { FactoryGirl.create_list(:term_registration, 3, welcomed_at: 2.days.ago) }
      let!(:not_welcomed_term_registrations) { FactoryGirl.create_list(:term_registration, 3, welcomed_at: nil) }

      describe '.welcomed' do
        it 'returns term_registrations which have been welcomed' do
          expect(described_class.welcomed).to match_array(welcomed_term_registrations)
        end
      end

      describe '.waiting_for_welcome' do
        it 'returns term_registrations which have not been welcomed' do
          expect(described_class.waiting_for_welcome).to match_array(not_welcomed_term_registrations)
        end
      end
    end
  end

  context 'validations' do
    let(:term) { FactoryGirl.create(:term) }
    let(:another_term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

    describe 'ensuring term consistency' do
      it 'is valid when tutorial group is in the same term' do
        term_registration = build(:term_registration, tutorial_group: tutorial_group, term: term)

        expect(term_registration).to be_valid
      end

      it 'is not valid when term of tutorial group differs' do
        term_registration = build(:term_registration, tutorial_group: tutorial_group, term: another_term)

        expect(term_registration).not_to be_valid
      end
    end
  end

  context 'students' do
    let(:subject) { build :term_registration, :student }

    it { is_expected.to validate_presence_of :tutorial_group }
  end

  context 'tutors' do
    let(:subject) { build :term_registration, :tutor }

    it { is_expected.to validate_presence_of :tutorial_group }
  end

  context 'lecturers' do
    let(:subject) { build :term_registration, :lecturer }

    it 'validates absence of tutorial_group_id' do
      subject.tutorial_group = nil
      expect(subject).to be_valid

      subject.tutorial_group = FactoryGirl.create(:tutorial_group)
      expect(subject).not_to be_valid
    end
  end



  context 'updating points' do
    let(:term) { create :term }
    let(:exercises) { create_list :exercise, 2, term: term }
    let(:term_registration) do
      create :term_registration, :student, term: term
    end

    before :each do
      exercises.each do |exercise|
        create :exercise_registration, exercise: exercise, term_registration: term_registration, submission: create(:submission)
      end
      ExerciseRegistration.update_all(points: 12)
    end

    it 'updates points correctly' do
      term_registration.update!(points: nil)
      term_registration.update_points!

      expect(term_registration.reload.points).to eq(12 * 2)
    end
  end
end
