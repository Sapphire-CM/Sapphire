require 'rails_helper'

describe ResultPublicationPolicy do
  subject { Pundit.policy(user, result_publication) }

  let(:result_publication) { FactoryGirl.create(:result_publication) }

  context 'as an admin' do
    let(:user) { FactoryGirl.build(:account, :admin) }

    it { is_expected.to permit_authorization :index }
    it { is_expected.to permit_authorization :update }
  end
end
