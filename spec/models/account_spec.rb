require 'rails_helper'

describe Account do
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
      subject { FactoryGirl.build(:account, matriculation_number: "1234567" )}
      it 'returns the default password based on matriculation number' do
        expect(subject.default_password).to eq("sapphire1234567")
        subject.matriculation_number = subject.matriculation_number.reverse

        expect(subject.default_password).to eq("sapphire7654321")
      end
    end
  end

  context 'student' do
    let(:term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) do
      account = FactoryGirl.create(:account)
      FactoryGirl.create(:term_registration, :student, account: account, term: term, tutorial_group: tutorial_group)
      account
    end

    it 'is able to tell if the account is a student of a term' do
      expect(user).to be_student_of_term(term)
      expect(user).not_to be_student_of_term(FactoryGirl.create(:term))
    end
  end

  context 'student' do
    let(:term) { FactoryGirl.create(:term) }
    let(:user) { FactoryGirl.create(:account, :admin) }

    it 'is able to tell that the account is not a student of a term' do
      expect(user).not_to be_student_of_term(term)
    end
  end
end
