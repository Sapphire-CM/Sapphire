require "rails_helper"

RSpec.describe SubmissionExtractionService do
  describe 'initialization' do
    let(:submission_asset) { FactoryGirl.build(:submission_asset) }

    it 'requires a submission_asset as parameter' do
      service = nil
      expect do
        service = described_class.new(submission_asset)
      end.not_to raise_error

      expect(service.submission_asset).to eq(submission_asset)
    end

    it 'sets default values' do
      service = described_class.new(submission_asset)

      expect(service.errors).to eq([])
      expect(service.created_assets).to eq([])
    end
  end

  describe '#perform' do
    context 'with valid ZIP archive' do
      it 'extracts zip asset'
      it 'creates a event'
      it 'removes zip asset, if extraction succeeded'
    end

    context 'with invalid ZIP archive' do
      it 'checks if the asset is a zip archive'
      it 'sets errors for failed submission assets'
      it 'does create an event indicating failed extraction'
      it 'does not remove asset if errors occured'
    end
  end

  describe '#accumulated_filesize' do
    it 'returns the sum of filesizes after extracting all files'
  end

  # ==========================================================
  # = Moved here from student_submissions_controller#extract =
  # ==========================================================
  #  let!(:term_registration) { current_account.term_registrations.first }
  #  let!(:exercise) { FactoryGirl.create :exercise, term: term_registration.term }
  #  let!(:submission) { FactoryGirl.create :submission, exercise: exercise, submitter: current_account }
  #  let!(:exercise_registration) { FactoryGirl.create :exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission }
  #
  #  def file_extraction_params(file, extract = '1')
  #    {
  #      id: Base64.encode64(file).strip,
  #      extract: extract,
  #    }
  #  end
  #
  #  it 'extracts the checked files' do
  #    sa = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')
  #
  #    params = {
  #      exercise_id: exercise.id,
  #      submission_assets: {
  #        sa.id.to_s => {
  #          'file_0' => file_extraction_params('simple_submission.txt'),
  #          'file_1' => file_extraction_params('import_data.csv'),
  #          'file_2' => file_extraction_params('some_folder/submission.zip'),
  #          'file_3' => file_extraction_params('some_other_folder/some_dir/import_data_invalid_parsing.csv'),
  #        }
  #      }
  #    }
  #
  #    expect do
  #      post :extract, params
  #    end.to change(Events::Submission::Extracted, :count).by(1)
  #    submission.reload
  #
  #    current_submission_assets = submission.submission_assets.map { |sa| [File.basename(sa.file.to_s), sa.path] }
  #
  #    # original archive should be removed
  #    expect(SubmissionAsset.exists?(sa.id)).to eq(false)
  #    expect(current_submission_assets).not_to include(['submission_nested_archives.zip', ''])
  #
  #    # files extracted from archive
  #    expect(current_submission_assets).to include(['simple_submission.txt', ''])
  #    expect(current_submission_assets).to include(['import_data.csv', ''])
  #    expect(current_submission_assets).to include(['submission.zip', 'some_folder'])
  #    expect(current_submission_assets).to include(['import_data_invalid_parsing.csv', 'some_other_folder/some_dir'])
  #
  #    # files not extracted from archive
  #    expect(current_submission_assets).not_to include(['import_data_not.csv', ''])
  #  end
  #
  #  it 'checks the excluded patterns' do
  #    sa = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')
  #
  #    params = {
  #      exercise_id: exercise.id,
  #      submission_assets: {
  #        sa.id.to_s => {
  #          'file_0' => file_extraction_params('simple_submission.txt'),
  #          'file_1' => file_extraction_params('.DS_Store',),
  #          'file_2' => file_extraction_params('.git/config'),
  #        }
  #      }
  #    }
  #
  #    post :extract, params
  #    submission.reload
  #
  #    current_submission_assets = submission.submission_assets.map { |sa| [File.basename(sa.file.to_s), sa.path] }
  #
  #    expect(current_submission_assets).to include(['simple_submission.txt', ''])
  #    expect(current_submission_assets).not_to include(['.DS_Store', ''])
  #    expect(current_submission_assets).not_to include(['config', '.git'])
  #  end


  # it 'checks the new submission size properly' do
  #   exercise.update! enable_max_upload_size: true, maximum_upload_size: 800
  #   sa = submission.submission_assets.create file: prepare_static_test_file('simple_submission.txt')
  #   sa = submission.submission_assets.create file: prepare_static_test_file('submission_nested_archives.zip')
  #
  #   params = {
  #     exercise_id: exercise.id,
  #     submission_assets: {
  #       sa.id.to_s => {
  #         'file_0' => file_extraction_params('simple_submission.txt'),
  #       }
  #     }
  #   }
  #   expect do
  #     post :extract, params
  #   end.not_to change(Events::Submission::Extracted, :count)
  #
  #   expect(response).to redirect_to(catalog_exercise_student_submission_path(exercise))
  #   expect(flash[:alert]).to eq('Maximum upload size reached')
  # end
end
