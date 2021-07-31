require 'rails_helper'

RSpec.describe TermRegistration do

  describe 'db columns' do
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:positive_grade).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:receives_grade).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:role).of_type(:integer).with_options(default: :student) }

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

  describe 'delegations' do
    it { is_expected.to delegate_method(:title).to(:tutorial_group).with_prefix(true) }
  end

  describe 'methods' do
    describe '.search' do
      let(:account_1) { FactoryGirl.create(:account, forename: "John", surname: "Doe", matriculation_number: "12345678") }
      let(:account_2) { FactoryGirl.create(:account, forename: "Jane", surname: "Doe", matriculation_number: "87654321") }

      let!(:student_term_registration_1) { FactoryGirl.create(:term_registration, :student, account: account_1) }
      let!(:tutor_term_registration_1) { FactoryGirl.create(:term_registration, :tutor, account: account_1) }
      let!(:tutor_term_registration_2) { FactoryGirl.create(:term_registration, :tutor, account: account_1) }
      let!(:lecturer_term_registration_1) { FactoryGirl.create(:term_registration, :lecturer, account: account_1) }

      let!(:student_term_registration_2) { FactoryGirl.create(:term_registration, :student, account: account_2) }
      let!(:tutor_term_registration_3) { FactoryGirl.create(:term_registration, :tutor, account: account_2) }

      let(:term_registrations_of_account_1) {
        [
          student_term_registration_1,
          tutor_term_registration_1,
          tutor_term_registration_2,
          lecturer_term_registration_1
        ]
      }
      let(:term_registrations_of_account_2) {
        [
          student_term_registration_2,
          tutor_term_registration_3
        ]
      }

      it 'delegates to Account' do
        query = "John Doe"
        expect(Account).to receive(:search).with(query).and_call_original

        described_class.search(query)
      end

      it 'returns term_registrations when searched for forename' do
        expect(described_class.search("Jane")).to match_array(term_registrations_of_account_2)
      end

      it 'returns term_registrations when searched for surname' do
        expect(described_class.search("Doe")).to match_array(term_registrations_of_account_1 + term_registrations_of_account_2)
      end

      it 'returns term_registrations when searched for matriculation number' do
        expect(described_class.search("12345678")).to match_array(term_registrations_of_account_1)
      end
    end

    describe '#negative_grade' do
      it 'returns the inverse of positive_grade' do
        subject.positive_grade = true
        expect(subject.negative_grade?).to be_falsey

        subject.positive_grade = false
        expect(subject.negative_grade?).to be_truthy
      end
    end

    describe '#staff?' do
      it 'returns true if role is lecturer' do
        subject.role = :lecturer

        expect(subject).to be_staff
      end

      it 'returns true if role is tutor' do
        subject.role = :tutor

        expect(subject).to be_staff
      end

      it 'returns false if role is student' do
        subject.role = :student

        expect(subject).not_to be_staff
      end

      it 'returns false if role is blank' do
        subject.role = nil

        expect(subject).not_to be_staff
      end
    end

    describe '#update_points' do
      let(:term) { FactoryGirl.create(:term) }
      let(:exercises) { FactoryGirl.create_list(:exercise, 2, term: term) }

      let(:submissions) { exercises.map { |exercise| FactoryGirl.create(:submission, exercise: exercise) } }
      let!(:exercise_registrations) { submissions.map { |submission| FactoryGirl.create(:exercise_registration, exercise: submission.exercise, term_registration: subject, submission: submission) }}

      subject { FactoryGirl.create(:term_registration, :student, term: term) }

      before :each do
        exercise_registrations.first.update(points: 12)
        exercise_registrations.second.update(points: 30)
      end

      it 'sums up all exercise registrations' do
        subject.points = nil
        subject.update_points

        expect(subject.points).to eq(42)
      end

      it 'excludes inactive exercise registrations' do
        exercise_registrations.first.update(active: false)

        subject.points = nil
        subject.update_points

        expect(subject.points).to eq(30)
      end
    end

    describe '#update_points!' do
      it 'calls #update_points then #save!' do
        expect(subject).to receive(:update_points).ordered
        expect(subject).to receive(:save!).ordered

        subject.update_points!
      end
    end

    describe '#welcomed?' do
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
        expect(described_class.students.ordered_by_matriculation_number).to eq(described_class.students.joins(:account).merge(Account.order(:matriculation_number)))
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
end
