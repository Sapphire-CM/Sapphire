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

      it { should permit :index }
    end

    context "as a lecturer" do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.lecturer_registrations.first.term }

      it { should permit :index }
    end

    context "as a tutor" do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.tutor_registrations.first.term }

      it { should permit :index }
    end


    context "as a student" do
      let(:user) { FactoryGirl.create(:account, :student)}
      let(:term) { user.student_registrations.first.term}

      it { should permit :index }
    end
  end

  context do
    subject { Pundit.policy(user, exercise) }


    context "as an admin" do
      let(:user) { FactoryGirl.create(:account, :admin) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }

      it { should permit :new}
      it { should permit :create}
      it { should permit :edit}
      it { should permit :update}
      it { should permit :destroy}
    end

    context "as a lecturer" do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.lecturer_registrations.first.term }

      it { should permit :new}
      it { should permit :create}
      it { should permit :edit}
      it { should permit :update}
      it { should permit :destroy}
    end

    context "as a tutor" do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.tutor_registrations.first.term }

      it { should_not permit :new}
      it { should_not permit :create}
      it { should_not permit :edit}
      it { should_not permit :update}
      it { should_not permit :destroy}
    end

    context "as a student" do
      let(:user) { FactoryGirl.create(:account, :student)}
      let(:term) { user.student_registrations.first.term}

      it { should_not permit :new}
      it { should_not permit :create}
      it { should_not permit :edit}
      it { should_not permit :update}
      it { should_not permit :destroy}
    end
  end
end