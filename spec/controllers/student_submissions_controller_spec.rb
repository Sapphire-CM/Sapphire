require 'rails_helper'

RSpec.describe StudentSubmissionsController do
  render_views
  include_context 'active_student_session_context'

  describe 'GET show' do
    context 'as student registered to a term' do
      it 'shows the submission' do
        term_registration = @current_account.term_registrations.first
        term = term_registration.term
        exercise = FactoryGirl.create :exercise, term: term

        get :show, exercise_id: exercise.id

        expect(response).to have_http_status(:success)
        expect(assigns(:term)).to eq(term)
        expect(assigns(:exercise)).to eq(exercise)
      end
    end

    context 'as unassociated user' do
      it 'redirect somewhere else' do
        term = FactoryGirl.create :term
        exercise = FactoryGirl.create :exercise, term: term

        get :show, exercise_id: exercise.id

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'POST create' do
    let(:exercise) { FactoryGirl.create :exercise, term: @current_account.term_registrations.first.term }

    describe 'with valid params' do
      context 'creates a new submission' do
        (0..2).each do |assets_count|
          it "with #{assets_count} submission_assets" do
            valid_attributes = {
              exercise_id: exercise.id,
              submission: {
                submission_assets_attributes: {}
              }
            }

            (1..assets_count).each do |asset|
              valid_attributes[:submission][:submission_assets_attributes]["#{asset}"] = {
                file: Rack::Test::UploadedFile.new(FactoryGirl.create(:submission_asset).file.to_s, 'text/html')
              }
            end

            expect do
              expect do
                post :create, valid_attributes
              end.to change(SubmissionAsset, :count).by(assets_count)
            end.to change(Submission, :count).by(1)

            expect(response).to redirect_to(exercise_student_submission_path(exercise))
          end
        end

        it 'redirects to catalog if a ZIP archive was uploaded' do
          valid_attributes = {
            exercise_id: exercise.id,
            submission: {
              submission_assets_attributes: {
                '0' => {
                  file: Rack::Test::UploadedFile.new(prepare_static_test_file('submission.zip'), 'application/zip')
                }
              }
            }
          }

          post :create, valid_attributes

          expect(response).to redirect_to(catalog_exercise_student_submission_path(exercise))
        end
      end
    end

    describe 'with invalid params' do
      it 'shows an error if file is too large' do
        exercise.update! enable_max_upload_size: true, maximum_upload_size: 42

        invalid_attributes = {
          exercise_id: exercise.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                file: Rack::Test::UploadedFile.new(prepare_static_test_file('submission.zip'), 'application/zip')
              }
            }
          }
        }

        expect do
          expect do
            post :create, invalid_attributes
          end.to change(SubmissionAsset, :count).by(0)
        end.to change(Submission, :count).by(0)

        expect(response).to have_http_status(:success)
        expect(response).to render_template('show')
        expect(flash[:alert]).to eq('Submission upload failed!')
        expect(response.body).to have_content('Upload too large')
        expect(assigns(:submission).errors.full_messages).to include('Upload too large')
      end

      it 'redirects to submission page' do
        invalid_attributes = {
          exercise_id: exercise.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                file: ''
              }
            }
          }
        }

        expect do
          expect do
            post :create, invalid_attributes
          end.to change(SubmissionAsset, :count).by(0)
        end.to change(Submission, :count).by(1)

        expect(response).to redirect_to(exercise_student_submission_path(exercise))
      end
    end
  end

  describe 'PATCH update' do
    let(:term_registration) { @current_account.term_registrations.first }
    let(:exercise) { FactoryGirl.create :exercise, term: term_registration.term }
    let(:submission) { FactoryGirl.create :submission, exercise: exercise, submitter: @current_account }
    let(:submission_asset) { FactoryGirl.create :submission_asset, submission: submission }

    describe 'with valid params' do
      it 'creates a a new submission' do
        FactoryGirl.create :exercise_registration,
          exercise: exercise,
          term_registration: term_registration,
          submission: submission

        valid_attributes = {
          exercise_id: exercise.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                id: submission_asset.id,
                file: Rack::Test::UploadedFile.new(FactoryGirl.create(:submission_asset).file.to_s, 'text/html')
              }
            }
          }
        }

        submission.update! submitted_at: 42.days.ago

        expect do
          expect do
            expect do
              put :update, valid_attributes
            end.to change(SubmissionAsset, :count).by(0)
          end.to change(Submission, :count).by(0)

          submission.reload
        end.to change(submission, :submitted_at)

        expect(response).to redirect_to(exercise_student_submission_path(exercise))
      end

      it 'redirects to catalog if a ZIP archive was uploaded' do
        FactoryGirl.create :exercise_registration,
          exercise: exercise,
          term_registration: term_registration,
          submission: submission

        valid_attributes = {
          exercise_id: exercise.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                id: submission_asset.id,
                file: Rack::Test::UploadedFile.new(prepare_static_test_file('submission.zip'), 'application/zip')
              }
            }
          }
        }

        submission.update! submitted_at: 42.days.ago

        put :update, valid_attributes

        expect(response).to redirect_to(catalog_exercise_student_submission_path(exercise))
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end

  describe 'GET catalog' do
    let!(:term_registration) { @current_account.term_registrations.first }
    let!(:exercise) { FactoryGirl.create :exercise, term: term_registration.term }
    let!(:submission) { FactoryGirl.create :submission, exercise: exercise, submitter: @current_account }
    let!(:exercise_registration) { FactoryGirl.create :exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission }

    it 'redirects if no archives are found' do
      get :catalog, exercise_id: exercise.id

      expect(response).to redirect_to(exercise_student_submission_path(exercise))
    end

    it 'lists archive content' do
      sa1 = submission.submission_assets.create file: prepare_static_test_file('submission.zip')
      sa2 = submission.submission_assets.create file: prepare_static_test_file('submission_2.zip')

      get :catalog, exercise_id: exercise.id

      expect(response).to have_http_status(:success)
      expect(response.body).to have_content(File.basename(sa1.file.to_s))
      expect(response.body).to have_content(File.basename(sa2.file.to_s))
      expect(assigns(:archives)).to match_array(submission.submission_assets.where(content_type: 'application/zip'))
    end

    it 'does not list excluded files and patterns' do
      sa1 = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')

      get :catalog, exercise_id: exercise.id

      expect(response).to have_http_status(:success)
      expect(response.body).to have_content(File.basename(sa1.file.to_s))
      expect(response.body).to have_content('simple_submission.txt')
      expect(response.body).not_to have_content('.git')
      expect(response.body).not_to have_content('.DS_Store')
    end
  end

  describe 'POST extract' do
    let!(:term_registration) { @current_account.term_registrations.first }
    let!(:exercise) { FactoryGirl.create :exercise, term: term_registration.term }
    let!(:submission) { FactoryGirl.create :submission, exercise: exercise, submitter: @current_account }
    let!(:exercise_registration) { FactoryGirl.create :exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission }

    it 'extracts the checked files' do
      sa = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')

      params = {
        exercise_id: exercise.id,
        submission_assets: {
          sa.id.to_s => {
            "file_0" => { full_path: 'simple_submission.txt', extract: '1' },
            "file_1" => { full_path: 'import_data.csv', extract: '1' },
            "file_2" => { full_path: 'some_folder/submission.zip', extract: '1' },
            "file_3" => { full_path: 'some_other_folder/some_dir/import_data_invalid_parsing.csv', extract: '1' },
          }
        }
      }

      post :extract, params
      submission.reload

      current_submission_assets = submission.submission_assets.map { |sa| [File.basename(sa.file.to_s), sa.path] }

      # original archive should be removed
      expect(SubmissionAsset.exists?(sa.id)).to eq(false)
      expect(current_submission_assets).not_to include(['submission_nested_archives.zip', ''])

      # files extracted from archive
      expect(current_submission_assets).to include(['simple_submission.txt', ''])
      expect(current_submission_assets).to include(['import_data.csv', ''])
      expect(current_submission_assets).to include(['submission.zip', 'some_folder'])
      expect(current_submission_assets).to include(['import_data_invalid_parsing.csv', 'some_other_folder/some_dir'])

      # files not extracted from archive
      expect(current_submission_assets).not_to include(['import_data_not.csv', ''])
    end

    it 'checks the excluded patterns' do
      sa = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')

      params = {
        exercise_id: exercise.id,
        submission_assets: {
          sa.id.to_s => {
            "file_0" => { full_path: 'simple_submission.txt', extract: '1' },
            "file_1" => { full_path: '.DS_Store', extract: '1' },
            "file_2" => { full_path: '.git/config', extract: '1' },
          }
        }
      }

      post :extract, params
      submission.reload

      current_submission_assets = submission.submission_assets.map { |sa| [File.basename(sa.file.to_s), sa.path] }

      expect(current_submission_assets).to include(['simple_submission.txt', ''])
      expect(current_submission_assets).not_to include(['.DS_Store', ''])
      expect(current_submission_assets).not_to include(['config', '.git'])
    end

    it 'checks the new submission size properly' do
      exercise.update! enable_max_upload_size: true, maximum_upload_size: 800
      sa = submission.submission_assets.create file: prepare_static_test_file('simple_submission.txt')
      sa = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')

      params = {
        exercise_id: exercise.id,
        submission_assets: {
          sa.id.to_s => {
            "file_0" => { full_path: 'simple_submission.txt', extract: '1' },
          }
        }
      }

      post :extract, params

      expect(response).to redirect_to(catalog_exercise_student_submission_path(exercise))
      expect(flash[:alert]).to eq('Maximum upload size reached')
    end
  end
end
