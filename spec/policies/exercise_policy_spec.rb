require 'rails_helper'

describe ExercisePolicy do
  let(:index_exercise_policy_record) do
    Struct.new :term do
      def policy_class
        ExercisePolicy
      end
    end
  end

  let(:term) { FactoryGirl.create(:term) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }

  context "for index" do
    subject { ExercisePolicy.new(user, term) }

    context "as an admin" do
      let(:user) { FactoryGirl.create(:account, :admin) }

      it { is_expected.to permit_authorization :index }
    end

    context "as a lecturer" do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :index }
    end

    context "as a tutor" do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) {  user.term_registrations.tutors.first.term }

      it { is_expected.to permit_authorization :index }
    end


    context "as a student" do
      let(:user) { FactoryGirl.create(:account, :student)}
      let(:term) { user.term_registrations.students.first.term}

      it { is_expected.to permit_authorization :index }
    end
  end

  context do
    subject { Pundit.policy(user, exercise) }


    context "as an admin" do
      let(:user) { FactoryGirl.create(:account, :admin) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }

      it { is_expected.to permit_authorization :new}
      it { is_expected.to permit_authorization :create}
      it { is_expected.to permit_authorization :edit}
      it { is_expected.to permit_authorization :update}
      it { is_expected.to permit_authorization :destroy}
    end

    context "as a lecturer" do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :new}
      it { is_expected.to permit_authorization :create}
      it { is_expected.to permit_authorization :edit}
      it { is_expected.to permit_authorization :update}
      it { is_expected.to permit_authorization :destroy}
    end

    context "as a tutor" do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.not_to permit_authorization :new}
      it { is_expected.not_to permit_authorization :create}
      it { is_expected.not_to permit_authorization :edit}
      it { is_expected.not_to permit_authorization :update}
      it { is_expected.not_to permit_authorization :destroy}
    end

    context "as a student" do
      let(:user) { FactoryGirl.create(:account, :student)}
      let(:term) { user.term_registrations.students.first.term}

      it { is_expected.not_to permit_authorization :new}
      it { is_expected.not_to permit_authorization :create}
      it { is_expected.not_to permit_authorization :edit}
      it { is_expected.not_to permit_authorization :update}
      it { is_expected.not_to permit_authorization :destroy}
    end
  end
end
