require 'rails_helper'

describe TermRegistration do
  it { is_expected.to validate_presence_of :account }
  it { is_expected.to validate_presence_of :term }
  it { is_expected.to have_many :exercise_registrations }

  # this currently failes because of https://github.com/thoughtbot/shoulda-matchers/issues/535
  # it { is_expected.to validate_uniqueness_of(:account).scoped_to(:term_id)}

  it 'responds to #negative_grade' do
    term_registration = build(:term_registration, positive_grade: true)
    expect(term_registration.negative_grade?).to be_falsey
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

  context 'scopes' do
    let!(:lecturer_registrations) { FactoryGirl.create_list :term_registration, 3, :lecturer }
    let!(:tutor_registrations) { FactoryGirl.create_list :term_registration, 5, :tutor }
    let!(:student_registrations) { FactoryGirl.create_list :term_registration, 7, :student }

    it 'scopes lecturers' do
      expect(TermRegistration.lecturer).to eq(TermRegistration.lecturers)
      expect(TermRegistration.lecturer).to match_array(lecturer_registrations)
    end

    it 'scopes tutors' do
      expect(TermRegistration.tutor).to eq(TermRegistration.tutors)
      expect(TermRegistration.tutor).to match_array(tutor_registrations)
    end

    it 'scopes students' do
      expect(TermRegistration.student).to eq(TermRegistration.students)
      expect(TermRegistration.student).to match_array(student_registrations)
    end

    it 'scopes staff' do
      expect(TermRegistration.staff.map(&:id)).to match_array(lecturer_registrations.map(&:id) + tutor_registrations.map(&:id))
    end

    it 'ordered by matriculation number' do
      expect(TermRegistration.students.ordered_by_matriculation_number).to eq(TermRegistration.students.joins(:account).order { account.matriculation_number.asc })
    end
  end

  context 'updating points' do
    let(:term) { create :term }
    let(:exercises) { create_list :exercise, 2, term: term }
    let(:term_registration) do
      create :term_registration, :student, term: term
    end

    before :each do
      registrations = exercises.map do |exercise|
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
