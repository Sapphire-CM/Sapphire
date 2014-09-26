RSpec.shared_context "authenticated student" do
  let(:account) { create(:account, :student) }
  let(:term) { account.term_registrations.last.term }
  let(:course) { term.course }

  before :each do
    sign_in user
  end
end

RSpec.shared_context "authenticated admin" do
  let(:account) {create(:account, :admin)}

  before :each do
    sign_in account
  end
end