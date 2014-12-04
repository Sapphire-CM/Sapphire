require 'rails_helper'

RSpec.describe TutorialGroupsController do
  include_context 'active_admin_session_context'

  describe 'GET #index' do
    let(:term) { create(:term) }

    it "assigns @term" do
      get :index, term_id: term

      expect(assigns[:term]).to eq(term)
    end
  end
end
