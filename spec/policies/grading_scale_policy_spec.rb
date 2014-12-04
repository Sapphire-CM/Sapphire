require 'rails_helper'

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

    it { should permit_authorization :edit }
    it { should permit_authorization :update}
  end

  context "as a lecturer" do
    let(:user) { FactoryGirl.create(:account, :lecturer) }
    let(:term) { user.term_registrations.lecturers.first.term }

    it { should permit_authorization :edit}
    it { should permit_authorization :update}
  end

  context "as a tutor" do
    let(:user) { FactoryGirl.create(:account, :tutor) }
    let(:term) { user.term_registrations.tutors.first.term }

    it {should_not permit_authorization :edit}
    it {should_not permit_authorization :update}
  end

  context "as a student" do
    let(:user) { FactoryGirl.create(:account, :student)}
    let(:term) { user.term_registrations.students.first.term }

    it { should_not permit_authorization :edit }
    it { should_not permit_authorization :update}
  end

end
