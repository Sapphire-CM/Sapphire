require "spec_helper"

RSpec.describe TutorialGroupsController do
  describe 'GET #index' do
    include_context "authenticated admin"
    let(:term) { create(:term) }

    it "assigns @term" do
      get :index, term_id: term

      expect(assigns[:term]).to eq(term)
    end
  end
end