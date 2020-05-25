require 'rails_helper'

RSpec.describe Exercise::SubmissionsDiskUsageStatistics do
  let!(:filesystem_size) { 447 }
  let!(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, term: term }
  let(:submission_1) { FactoryGirl.create(:submission, exercise: exercise) }
  let!(:submission_asset_1) { FactoryGirl.create(:submission_asset, :plain_text, submission: submission_1) }
  let!(:submission_asset_2) { FactoryGirl.create(:submission_asset, submission: submission_1) }
  let(:submission_2) { FactoryGirl.create(:submission, exercise: exercise) }
  let!(:submission_asset_3) { FactoryGirl.create(:submission_asset, submission: submission_2) }
  let!(:stats) {Exercise::SubmissionsDiskUsageStatistics.new(exercise).submissions_disk_usage}

  describe '#sum' do
    it 'get sum of file size for the submissions of an exercise' do
      expect(stats.sum).to eq(3 * filesystem_size)
    end
  end
  
  describe '#average' do
    it 'get average file size for the submissions of an exercise' do
      expect(stats.average).to eq((3 * filesystem_size) / 2)
    end
  end
  
  describe '#minimum' do
    it 'get minimum file size for the submissions of an exercise' do
      expect(stats.minimum).to eq(filesystem_size)
    end
  end

  describe '#maximum' do
    it 'get maximum file size for the submissions of an exercise' do
      expect(stats.maximum).to eq(2 * filesystem_size)
    end
  end
end
