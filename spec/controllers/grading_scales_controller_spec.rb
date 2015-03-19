require 'rails_helper'

RSpec.describe GradingScalesController do
  #  render_views
  #  include_context 'active_admin_session_context'

  it 'needs to be implemented'

  let(:course) { term.course }
  let(:term) { create(:term) }

  before(:each) do
    sign_in(account)
  end

  describe 'GET /terms/:id/grading_scale/edit' do
    context 'as an admin' do
      let(:account) { create(:account, :admin) }

      it 'assigns @term' do
        get :edit, term_id: term.id

        expect(assigns[:term]).to eq(term)
      end

      it 'assigns @grading_scale' do
        get :edit, term_id: term.id

        expect(assigns(:grading_scale)).to be_present
      end
    end
  end

  describe 'PATCH /terms/:id/grading_scale' do
    context 'as an admin' do
      let(:account) { create(:account, :admin) }
      let(:grading_scale_params) { [[0, '5'], [100, '4'], [120, '3'], [140, '2'], [160, '1']] }

      it 'updates the grading scale' do
        term = FactoryGirl.create :term, points: 200
        term.send(:write_attribute, :grading_scale, grading_scale_params)
        term.reload

        expect {
          patch :update, term_id: term.id, term: { grading_scale: { '1' => '180' } }
          term.reload
        }.to change { term.read_attribute(:grading_scale) }

        expect(subject).to redirect_to(edit_term_grading_scale_path(term))
      end
    end
  end
end
