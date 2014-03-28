require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GradingScalePolicy do
  let(:term_policy_record) do
    Struct.new :term do
      def policy_class
        GradingScalePolicy
      end
    end
  end

  subject { Pundit.policy(user, term_policy_record.new(term)) }

  context "as an admin" do
    let(:user) { FactoryGirl.create(:account, :admin) }
    let(:term) { FactoryGirl.create(:term) }

    it { should permit :edit }
    it { should permit :update}
  end

  context "as a lecturer" do
    let(:user) { FactoryGirl.create(:account, :lecturer) }
    let(:term) { user.lecturer_registrations.first.term }

    it { should permit :edit}
    it { should permit :update}
  end

  context "as a tutor" do
    let(:user) { FactoryGirl.create(:account, :tutor) }
    let(:term) { user.tutor_registrations.first.term }

    it {should_not permit :edit}
    it {should_not permit :update}
  end

  context "as a student" do
    let(:user) { FactoryGirl.create(:account, :student)}
    let(:term) { user.student_registrations.first.term}

    it { should_not permit :edit }
    it { should_not permit :update}
  end

end