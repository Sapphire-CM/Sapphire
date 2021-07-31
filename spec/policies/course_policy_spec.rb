require 'rails_helper'

RSpec.describe CoursePolicy do
  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:course) { FactoryBot.create(:course) }

    describe 'scoping' do
      let!(:courses) { FactoryBot.create_list(:course, 2) + [course] }
      subject { described_class::Scope.new(account, Course.all) }

      it 'returns all courses' do
        expect(subject.resolve).to match_array(courses)
      end
    end

    describe 'permissions' do
      describe 'collections' do
        subject { described_class.new(account, nil) }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'members' do
        subject { described_class.new(account, course) }

        it { is_expected.to permit_authorization(:new) }
        it { is_expected.to permit_authorization(:create) }
        it { is_expected.to permit_authorization(:edit) }
        it { is_expected.to permit_authorization(:update) }
        it { is_expected.to permit_authorization(:destroy) }
        it { is_expected.to permit_authorization(:student_count) }
        it { is_expected.to permit_authorization(:create_term) }
      end
    end
  end

  context 'as lecturer' do
    let(:account) { FactoryBot.create(:account, :lecturer) }
    let(:term_registration) { account.term_registrations.lecturer.first }
    let(:term) { term_registration.term }
    let(:course) { term.course }

    describe 'scoping' do
      let!(:other_course) { FactoryBot.create(:course) }

      subject { described_class::Scope.new(account, Course.all) }

      it 'returns lectured courses' do
        expect(subject.resolve).to match_array([course])
      end
    end

    describe 'permissions' do
      context 'of other course' do
        let(:course) { FactoryBot.create(:course) }

        describe 'collections' do
          subject { described_class.new(account, nil) }

          it { is_expected.to permit_authorization(:index) }
          it { is_expected.not_to permit_authorization(:new) }
          it { is_expected.not_to permit_authorization(:create) }

        end

        describe 'members' do
          subject { described_class.new(account, course) }

          it { is_expected.not_to permit_authorization(:edit) }
          it { is_expected.not_to permit_authorization(:update) }
          it { is_expected.not_to permit_authorization(:destroy) }
          it { is_expected.not_to permit_authorization(:create_term) }
          it { is_expected.not_to permit_authorization(:student_count) }
        end
      end

      context 'of course' do
        describe 'collections' do
          subject { described_class.new(account, nil) }

          it { is_expected.to permit_authorization(:index) }
          it { is_expected.not_to permit_authorization(:new) }
          it { is_expected.not_to permit_authorization(:create) }
        end

        describe 'members' do
          subject { described_class.new(account, course) }

          it { is_expected.not_to permit_authorization(:edit) }
          it { is_expected.not_to permit_authorization(:update) }
          it { is_expected.not_to permit_authorization(:destroy) }
          it { is_expected.to permit_authorization(:create_term) }
          it { is_expected.to permit_authorization(:student_count) }
        end
      end
    end
  end

  context 'as tutor' do
    let(:account) { FactoryBot.create(:account, :tutor) }
    let(:term_registration) { account.term_registrations.tutor.first }
    let(:term) { term_registration.term }
    let(:course) { term.course }

    describe 'scoping' do
      let!(:other_course) { FactoryBot.create(:course) }

      subject { described_class::Scope.new(account, Course.all) }

      it 'returns tutored courses' do
        expect(subject.resolve).to match_array([course])
      end
    end

    describe 'permissions' do
      describe 'collections' do
        subject { described_class.new(account, nil) }

        it { is_expected.to permit_authorization(:index) }
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
      end

      describe 'members' do
        subject { described_class.new(account, course) }

        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
        it { is_expected.not_to permit_authorization(:create_term) }
        it { is_expected.to permit_authorization(:student_count) }
      end
    end
  end

  context 'as student' do
    let(:account) { FactoryBot.create(:account, :student) }
    let(:term_registration) { account.term_registrations.student.first }
    let(:term) { term_registration.term }
    let(:course) { term.course }

    describe 'scoping' do
      let!(:other_course) { FactoryBot.create(:course) }

      subject { described_class::Scope.new(account, Course.all) }

      it 'returns student courses' do
        expect(subject.resolve).to match_array([course])
      end
    end

    describe 'permissions' do
      describe 'collections' do
        subject { described_class.new(account, nil) }

        it { is_expected.to permit_authorization(:index) }
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
      end

      describe 'members' do
        subject { described_class.new(account, course) }

        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
        it { is_expected.not_to permit_authorization(:create_term) }
        it { is_expected.not_to permit_authorization(:student_count) }
      end
    end
  end
end
