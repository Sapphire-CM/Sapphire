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
    before :all do
      create(:term_registration, :lecturer)
      create_list(:term_registration, 2, :tutor)
      create_list(:term_registration, 5, :student)
    end

    it 'scopes all lecturers' do
      expect(TermRegistration.lecturer).to eq(TermRegistration.lecturers)
      expect(TermRegistration.lecturers).to eq(TermRegistration.where(role: Roles::LECTURER))
      expect(TermRegistration.lecturers.count).to eq(1)
    end

    it 'scopes all tutors' do
      expect(TermRegistration.tutor).to eq(TermRegistration.tutors)
      expect(TermRegistration.tutors).to eq(TermRegistration.where(role: Roles::TUTOR))
      expect(TermRegistration.tutors.count).to eq(2)
    end

    it 'scopes all students' do
      expect(TermRegistration.student).to eq(TermRegistration.students)
      expect(TermRegistration.students).to eq(TermRegistration.where(role: Roles::STUDENT))
      expect(TermRegistration.students.count).to eq(5)
    end

    it 'orders by matriculation number' do
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
