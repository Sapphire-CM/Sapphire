require 'rails_helper'

RSpec.describe SystemDiskStatisticsController, type: :controller do
  render_views

  describe 'GET index' do
    context 'no courses' do
      include_context 'active_admin_session_context'
      it 'renders no courses and only overall system disk statistics' do
        get :index
        expect(response.body).to include('No courses present.')
        expect(response).to render_template("system_disk_statistics/_system_statistics_table")
      end
    end

    context 'courses as admin' do
      let!(:term) { FactoryGirl.create :term}
      include_context 'active_admin_session_context'
      it 'renders admins view of system statistics' do
        get :index
        expect(response).to render_template("system_disk_statistics/_system_statistics_table")
        expect(response).to render_template("system_disk_statistics/_term_statistics_table")
        expect(response.body).not_to include('[All Other Courses]')
      end
    end

    context 'courses as lecturer' do
      let!(:term_1) { FactoryGirl.create :term}
      let!(:term_2) { FactoryGirl.create :term}
      include_context 'active_lecturer_session_context'
      let!(:term_registration) { FactoryGirl.create(:term_registration, term: term_1, account: current_account) }
      it 'renders lecturers view of system statistics' do
        get :index
        expect(response).to render_template("system_disk_statistics/_system_statistics_table")
        expect(response).to render_template("system_disk_statistics/_term_statistics_table")
        expect(response).to render_template("system_disk_statistics/_other_courses_statistics_table")
        expect(response.body).to include('[All Other Courses]')
      end
    end
  end
end
