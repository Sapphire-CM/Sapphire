require 'rails_helper'

RSpec.describe TermPolicy do
  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:term) { FactoryBot.create(:term) }

    describe 'scoping' do
      subject { described_class::Scope.new(account, Term.all) }
      let(:terms) { FactoryBot.create_list(:term, 2) + [term] }

      it 'contains all terms' do
        expect(subject.resolve).to match_array(terms)
      end
    end

    describe 'permissions' do
      subject { Pundit.policy(account, term) }

      context 'new term' do
        let(:term) { FactoryBot.build(:term) }

        it { is_expected.to permit_authorization :new }
        it { is_expected.to permit_authorization :create }
      end

      context 'existing term' do
        it { is_expected.to permit_authorization :show }
        it { is_expected.to permit_authorization :edit }
        it { is_expected.to permit_authorization :update }
        it { is_expected.to permit_authorization :destroy }
        it { is_expected.to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.not_to permit_authorization :staff }
      end
    end
  end

  context 'as a student' do
    let(:account) { FactoryBot.create(:account, :student) }
    let(:term_registration) { account.term_registrations.student.first }

    describe 'scoping' do
      subject { described_class::Scope.new(account, Term.all) }
      let(:student_term) { term_registration.term }
      let(:sibling_term) { FactoryBot.create(:term, course: student_term.course) }
      let(:other_term) { FactoryBot.create(:term) }
      let!(:terms) { [student_term, sibling_term, other_term] }

      it 'contains only participated terms' do
        expect(subject.resolve).to match_array([student_term])
      end
    end

    describe 'permissions' do
      subject { Pundit.policy(account, term) }

      context 'new term' do
        let(:term) { FactoryBot.build(:term) }

        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

      context 'new sibling term' do
        let(:student_term) { term_registration.term }
        let(:term) { FactoryBot.build(:term, course: student_term.course) }

        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

      context 'student of term' do
        let(:term) { term_registration.term }

        it { is_expected.to permit_authorization :show }
        it { is_expected.not_to permit_authorization :edit }
        it { is_expected.not_to permit_authorization :update }
        it { is_expected.not_to permit_authorization :destroy }
        it { is_expected.not_to permit_authorization :points_overview }
        it { is_expected.to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.not_to permit_authorization :staff }
      end

      context 'student of other term' do
        let(:term) { FactoryBot.create(:term) }

        it { is_expected.not_to permit_authorization :show }
        it { is_expected.not_to permit_authorization :edit }
        it { is_expected.not_to permit_authorization :update }
        it { is_expected.not_to permit_authorization :destroy }
        it { is_expected.not_to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.not_to permit_authorization :staff }
      end
    end
  end

  context 'as a tutor' do
    let(:account) { FactoryBot.create(:account, :tutor) }
    let(:term_registration) { account.term_registrations.tutor.first }

    describe 'scoping' do
      subject { described_class::Scope.new(account, Term.all) }

      let(:tutor_term) { term_registration.term }
      let(:sibling_term) { FactoryBot.create(:term, course: tutor_term.course) }
      let(:other_term) { FactoryBot.create(:term) }
      let!(:terms) { [tutor_term, sibling_term, other_term] }

      it 'contains only tutored terms' do
        expect(subject.resolve).to match_array([tutor_term])
      end
    end

    describe 'permissions' do
      subject { Pundit.policy(account, term) }

      context 'new term' do
        let(:term) { FactoryBot.build(:term) }

        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

      context 'new sibling term' do
        let(:tutored_term) { term_registration.term }
        let(:term) { FactoryBot.build(:term, course: tutored_term.course) }

        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

      context 'of term' do
        let(:term) { term_registration.term }

        it { is_expected.to permit_authorization :show }
        it { is_expected.not_to permit_authorization :edit }
        it { is_expected.not_to permit_authorization :update }
        it { is_expected.not_to permit_authorization :destroy }
        it { is_expected.to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.to permit_authorization :tutor }
        it { is_expected.to permit_authorization :staff }
      end

      context 'of other term' do
        let(:term) { FactoryBot.create(:term) }

        it { is_expected.not_to permit_authorization :show }
        it { is_expected.not_to permit_authorization :edit }
        it { is_expected.not_to permit_authorization :update }
        it { is_expected.not_to permit_authorization :destroy }
        it { is_expected.not_to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.not_to permit_authorization :staff }
      end
    end
  end


  context 'as a lecturer' do
    let(:account) { FactoryBot.create(:account, :lecturer) }
    let(:term_registration) { account.term_registrations.lecturer.first }

    describe 'permissions' do
      subject { Pundit.policy(account, term) }

      context 'new term' do
        let(:term) { FactoryBot.build(:term) }

        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

      context 'new sibling term' do
        let(:lectured_term) { term_registration.term }
        let(:term) { FactoryBot.build(:term, course: lectured_term.course) }

        it { is_expected.to permit_authorization :new }
        it { is_expected.to permit_authorization :create }
      end

      context 'of term' do
        let(:term) { term_registration.term }

        it { is_expected.to permit_authorization :show }
        it { is_expected.to permit_authorization :edit }
        it { is_expected.to permit_authorization :update }
        it { is_expected.to permit_authorization :destroy }
        it { is_expected.to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.to permit_authorization :staff }
      end

      context 'of other term of lectured course' do
        let(:lectured_term) { term_registration.term }
        let(:course) { lectured_term.course }
        let(:term) { FactoryBot.create(:term, course: course) }

        it { is_expected.not_to permit_authorization :show }
        it { is_expected.not_to permit_authorization :edit }
        it { is_expected.not_to permit_authorization :update }
        it { is_expected.not_to permit_authorization :destroy }
        it { is_expected.not_to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.not_to permit_authorization :staff }
      end

      context 'of other term' do
        let(:term) { FactoryBot.create(:term) }

        it { is_expected.not_to permit_authorization :show }
        it { is_expected.not_to permit_authorization :edit }
        it { is_expected.not_to permit_authorization :update }
        it { is_expected.not_to permit_authorization :destroy }
        it { is_expected.not_to permit_authorization :points_overview }
        it { is_expected.not_to permit_authorization :student }
        it { is_expected.not_to permit_authorization :tutor }
        it { is_expected.not_to permit_authorization :staff }
      end
    end
  end
end
