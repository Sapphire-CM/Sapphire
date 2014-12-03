require 'rails_helper'

RSpec.shared_context 'authenticated student' do
  let(:account) { FactoryGirl.create :account, :student }
  let(:term) { account.term_registrations.last.term }
  let(:course) { term.course }

  before :each do
    sign_in account
  end
end

RSpec.shared_context 'authenticated admin' do
  let(:account) { FactoryGirl.create :account, :admin }

  before :each do
    sign_in account
  end
end
