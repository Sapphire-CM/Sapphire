require 'rails_helper'

RSpec.describe GradingScalesController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }

  describe 'GET index' do
    it 'renders the grading scale table' do
      get :index, params: { term_id: term.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template('_grade_overview')
    end
  end

  describe 'POST bulk_update' do
    context 'with valid params' do
      it 'works' do
        attributes = {
          term_id: term.id,
          grading_scales: {
            grading_scale_attributes: {
              "0" => {
                id: term.grading_scales.negative,
                max_points: 123,
              }
            }
          }
        }

        post :bulk_update, params: attributes
        term.reload

        expect(response).to redirect_to(term_grading_scales_path(term.id))
        expect(term.grading_scales.negative.max_points).to eq(123)
      end
    end

    context 'with invalid params' do
      it 'shows an error message' do
        attributes = {
          term_id: term.id,
          grading_scales: {
            grading_scale_attributes: {
              "0" => {
                id: term.grading_scales.ordered.first,
                max_points: 5,
              }
            }
          }
        }

        post :bulk_update, params: attributes
        term.reload

        expect(response).to redirect_to(term_grading_scales_path(term.id))
        expect(flash[:alert]).to eq('Failed updating grading scale!')
        expect(term.grading_scales.ordered.first.max_points).not_to eq(5)
      end
    end
  end
end
