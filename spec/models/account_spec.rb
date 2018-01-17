require 'rails_helper'

describe Account do
  describe 'db columns' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_token).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
    it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }
    it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:forename).of_type(:string) }
    it { is_expected.to have_db_column(:surname).of_type(:string) }
    it { is_expected.to have_db_column(:matriculation_number).of_type(:string) }
    it { is_expected.to have_db_column(:options).of_type(:text) }
    it { is_expected.to have_db_column(:failed_attempts).of_type(:integer) }
    it { is_expected.to have_db_column(:unlock_token).of_type(:string) }
    it { is_expected.to have_db_column(:locked_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:admin).of_type(:boolean) }

  end

  describe 'associations' do
    it { is_expected.to have_many(:term_registrations).dependent(:destroy) }
    it { is_expected.to have_many(:tutorial_groups).through(:term_registrations) }
    it { is_expected.to have_many(:email_addresses).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:forename) }
    it { is_expected.to validate_presence_of(:surname) }

    it { is_expected.not_to validate_presence_of(:matriculation_number) }
    it { is_expected.to validate_length_of(:matriculation_number).is_at_least(7).is_at_most(8) }
    it { is_expected.to validate_numericality_of(:matriculation_number) }
    it { is_expected.to validate_uniqueness_of(:matriculation_number) }

    it "allows blank matriculation numbers" do
      subject.matriculation_number = ""

      subject.valid?
      expect(subject.errors[:matriculation_number]).not_to be_present
    end

    pending "uniqueness of email adresses"
  end

  describe 'scopes' do
    describe '.admins' do
      let!(:admin_accounts) { FactoryGirl.create_list(:account, 3, :admin) }
      let!(:other_accounts) { FactoryGirl.create_list(:account, 3) }

      it 'only returns sapphire admins' do
        expect(described_class.admins).to match_array(admin_accounts)
      end
    end

    describe '.search' do
      let(:matriculation_number_prefix) { "110000" }
      let(:first_account) { FactoryGirl.create(:account, email: "student1@student.tugraz.at", forename: "Matthias", surname: "Link", matriculation_number: "1100000") }
      let(:second_account) { FactoryGirl.create(:account, email: "student2@student.tugraz.at", forename: "Thomas", surname: "Kriechbaumer", matriculation_number: "1100001") }
      let(:third_account) { FactoryGirl.create(:account, email: "lecturerer@student.tugraz.at", forename: "Keith", surname: "Andrews") }

      let!(:accounts) { [first_account, second_account, third_account] }

      it 'searches for forenames' do
        expect(described_class.search(first_account.forename)).to match_array([first_account])
      end

      it 'searches for surnames' do
        expect(described_class.search(third_account.surname)).to match_array([third_account])
      end

      it 'searches for matriculation numbers' do
        expect(described_class.search(second_account.matriculation_number)).to match_array([second_account])
      end

      it 'searches for email addresses' do
        expect(described_class.search(first_account.email)).to match_array([first_account])
      end

      it 'searches for concatinated strings by splitting them' do
        expect(described_class.search([second_account.forename, second_account.matriculation_number].join(" "))).to match([second_account])
      end

      it 'searches for partial strings' do
        expect(described_class.search([third_account.forename[0..2], third_account.surname[0..2]].join(" "))).to match([third_account])
      end

      it 'returns multiple results' do
        expect(described_class.search(matriculation_number_prefix)).to match_array([first_account, second_account])
      end
    end

    %w(students tutors lecturers).each do |role|
      pending ".#{role}_for_term"
    end
  end

  describe 'serialization' do
    pending '#options'
  end

  describe 'methods' do
    describe '#fullname' do
      subject { FactoryGirl.build(:account, forename: "Matthias", surname: "Link") }

      it 'returns a concatinated name, forename first' do
        expect(subject.fullname).to eq("Matthias Link")
      end
    end

    describe '#reverse_fullname' do
      subject { FactoryGirl.build(:account, forename: "Matthias", surname: "Link") }

      it 'returns a concatinated name, surname first' do
        expect(subject.reverse_fullname).to eq("Link Matthias")
      end
    end

    describe '#default_password' do
      subject { FactoryGirl.build(:account, matriculation_number: "1234567") }

      it 'returns the default password based on matriculation number' do
        expect(subject.default_password).to eq("sapphire1234567")
        subject.matriculation_number = subject.matriculation_number.reverse

        expect(subject.default_password).to eq("sapphire7654321")
      end
    end

    describe '#student_of_term?' do
      let(:term) { FactoryGirl.create(:term) }
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, :student, tutorial_group: tutorial_group, term: term, account: subject) }
      let!(:another_term) { FactoryGirl.create(:term) }

      subject { FactoryGirl.create(:account) }

      it 'returns true if user is student of term' do
        expect(subject).to be_student_of_term(term)
      end

      it 'returns false if user is not a student of term' do
        expect(subject).not_to be_student_of_term(another_term)
      end
    end

    describe '#tutor_of_term?' do
      let(:term) { FactoryGirl.create(:term) }
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, tutorial_group: tutorial_group, term: term, account: subject) }
      let!(:another_term) { FactoryGirl.create(:term) }

      subject { FactoryGirl.create(:account) }

      it 'returns true if user is tutor of term' do
        expect(subject).to be_tutor_of_term(term)
      end

      it 'returns false if user is not a tutor of term' do
        expect(subject).not_to be_tutor_of_term(another_term)
      end
    end

    describe '#lecturer_of_term?' do
      let(:term) { FactoryGirl.create(:term) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: subject) }
      let!(:another_term) { FactoryGirl.create(:term) }

      subject { FactoryGirl.create(:account) }

      it 'returns true if user is tutor of term' do
        expect(subject).to be_lecturer_of_term(term)
      end

      it 'returns false if user is not a tutor of term' do
        expect(subject).not_to be_lecturer_of_term(another_term)
      end
    end

    describe '#staff_of_term?' do
      let(:tutor_term) { FactoryGirl.create(:term) }
      let(:tutor_tutorial_group) { FactoryGirl.create(:tutorial_group, term: tutor_term) }
      let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, tutorial_group: tutor_tutorial_group, term: tutor_term, account: subject) }

      let(:student_term) { FactoryGirl.create(:term) }
      let(:student_tutorial_group) { FactoryGirl.create(:tutorial_group, term: student_term) }
      let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, tutorial_group: student_tutorial_group, term: student_term, account: subject) }

      let(:lecturer_term) { FactoryGirl.create(:term) }
      let!(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: lecturer_term, account: subject) }

      let!(:another_term) { FactoryGirl.create(:term) }

      subject { FactoryGirl.create(:account) }

      it 'returns true if user is tutor of term' do
        expect(subject).to be_staff_of_term(tutor_term)
      end

      it 'returns true if user is lecturer of term' do
        expect(subject).to be_staff_of_term(lecturer_term)
      end

      it 'returns false if user is a student of term' do
        expect(subject).not_to be_staff_of_term(student_term)
      end

      it 'returns false if user is not a staff member of term' do
        expect(subject).not_to be_staff_of_term(another_term)
      end
    end

    describe '#staff_of_course?' do
      subject { FactoryGirl.create(described_class.to_s.underscore.to_sym) }

      let(:student_course) { student_term.course }
      let(:student_term) { FactoryGirl.create(:term) }
      let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: student_term, account: subject) }

      let(:tutor_course) { tutor_term.course }
      let(:tutor_term) { FactoryGirl.create(:term) }
      let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: tutor_term, account: subject) }

      let(:lecturer_course) { lecturer_term.course }
      let(:lecturer_term) { FactoryGirl.create(:term) }
      let!(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: lecturer_term, account: subject) }

      let(:another_course) { another_term.course }
      let(:another_term) { FactoryGirl.create(:term) }

      it 'returns true if account is lecturer of term' do
        expect(subject.staff_of_course?(lecturer_course)).to be_truthy
      end

      it 'returns true if account is tutor of term' do
        expect(subject.staff_of_course?(tutor_course)).to be_truthy
      end

      it 'returns false if account is student of term' do
        expect(subject.staff_of_course?(student_course)).to be_falsey
      end

      it 'returns false if account not associated with term' do
        expect(subject.staff_of_course?(another_course)).to be_falsey
      end
    end

    pending '#tutor_of_tutorial_group?'
    pending '#lecturer_of_any_term_in_course?'
    pending '#associated_with_term?'

    pending '#submissions_for_term'
    pending '#submission_for_exercise'
    pending '#tutorial_group_for_term'
  end
end
