require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResultPublicationPolicy do
  subject { Pundit.policy(user, result_publication) }

  let(:result_publication) { FactoryGirl.create(:result_publication) }

  context "as an admin" do
    let(:user) {FactoryGirl.build(:account, :admin)}

    it {should permit_authorization :index}
    it {should permit_authorization :update}
  end
end