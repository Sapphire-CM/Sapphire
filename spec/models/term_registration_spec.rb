require 'spec_helper'

describe TermRegistration do
  it { should validate_presence_of :account_id }
  it { should validate_presence_of :term_id }
  it { should validate_presence_of :role }
  it { should ensure_inclusion_of(:role).in_array Roles::ALL }
  it { should validate_uniqueness_of(:account_id).scoped_to(:term_id)}
  it { should have_many :exercise_registrations }

  it "should respond to #negative_grade" do
    term_registration = build(:term_registration, positive_grade: true)
    expect(term_registration.negative_grade?).to be_false
  end

  context "students" do
    let(:subject) { build :term_registration, :student }

    it { should validate_presence_of :tutorial_group_id }
  end

  context "tutors" do
    let(:subject) { build :term_registration, :tutor }

    it { should validate_presence_of :tutorial_group_id }
  end

  context "lecturers" do
    let(:subject) { build :term_registration, :lecturer }

    it { should validate_absence_of :tutorial_group_id }
  end

  context "scopes" do
    before :all do
      create(:term_registration, :lecturer)
      create_list(:term_registration, 2, :tutor)
      create_list(:term_registration, 5, :student)
    end

    it "should scope all lecturers" do
      expect(TermRegistration.lecturers).to eq(TermRegistration.where(role: "lecturer"))
      expect(TermRegistration.lecturers.count).to eq(1)
    end

    it "should scope all tutors" do
      expect(TermRegistration.tutors).to eq(TermRegistration.where(role: "tutor"))
      expect(TermRegistration.tutors.count).to eq(2)
    end

    it "should scope all students" do
      expect(TermRegistration.students).to eq(TermRegistration.where(role: "student"))
      expect(TermRegistration.students.count).to eq(5)
    end

    it "should order by matriculation number" do
      expect(TermRegistration.students.ordered_by_matriculation_number).to eq(TermRegistration.students.joins(:account).order{ account.matriculation_number.asc })
    end
  end

  context "updating points" do
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

    it "should update points correctly" do
      term_registration.update!(points: nil)
      term_registration.update_points!

      expect(term_registration.reload.points).to eq(12 * 2)
    end
  end
end
