require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

      it { should permit_authorization :index }
    end

    context "as a lecturer" do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { should permit_authorization :index }
    end

    context "as a tutor" do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) {  user.term_registrations.tutors.first.term }

      it { should permit_authorization :index }
    end


    context "as a student" do
      let(:user) { FactoryGirl.create(:account, :student)}
      let(:term) { user.term_registrations.students.first.term}

      it { should permit_authorization :index }
    end
  end

  context do
    subject { Pundit.policy(user, exercise) }


    context "as an admin" do
      let(:user) { FactoryGirl.create(:account, :admin) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }

      it { should permit_authorization :new}
      it { should permit_authorization :create}
      it { should permit_authorization :edit}
      it { should permit_authorization :update}
      it { should permit_authorization :destroy}
    end

    context "as a lecturer" do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { should permit_authorization :new}
      it { should permit_authorization :create}
      it { should permit_authorization :edit}
      it { should permit_authorization :update}
      it { should permit_authorization :destroy}
    end

    context "as a tutor" do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { should_not permit_authorization :new}
      it { should_not permit_authorization :create}
      it { should_not permit_authorization :edit}
      it { should_not permit_authorization :update}
      it { should_not permit_authorization :destroy}
    end

    context "as a student" do
      let(:user) { FactoryGirl.create(:account, :student)}
      let(:term) { user.term_registrations.students.first.term}

      it { should_not permit_authorization :new}
      it { should_not permit_authorization :create}
      it { should_not permit_authorization :edit}
      it { should_not permit_authorization :update}
      it { should_not permit_authorization :destroy}
    end
  end
end