require 'rails_helper'

RSpec.describe Exercises::DiskUsageStatistics do
  let!(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, term: term }
  let(:submission_1) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:submission_asset_1) { FactoryGirl.create(:submission_asset, :plain_text, submission: submission_1) }
  let(:submission_asset_2) { FactoryGirl.create(:submission_asset, submission: submission_1) }
  let(:submission_2) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:submission_asset_3) { FactoryGirl.create(:submission_asset, submission: submission_2) }

  describe '#get_disk_usage_sum' do
    it 'get sum of file size for the submissions of an exercise' do
      submission_asset_1
      submission_asset_2
      submission_asset_3
      expect(exercise.get_disk_usage_sum).to eq(3 * 447)
    end
  end
  
  describe '#get_disk_usage_average' do
    it 'get average file size for the submissions of an exercise' do
      submission_asset_1
      submission_asset_2
      submission_asset_3
      expect(exercise.get_disk_usage_average.to_i).to eq((3 * 447) / 2)
    end
  end
  
  describe '#get_disk_usage_minimum' do
    it 'get minimum file size for the submissions of an exercise' do
      submission_asset_1
      submission_asset_2
      submission_asset_3
      expect(exercise.get_disk_usage_minimum).to eq(447)
    end
  end

  describe '#get_disk_usage_maximum' do
    it 'get maximum file size for the submissions of an exercise' do
      submission_asset_1
      submission_asset_2
      submission_asset_3
      expect(exercise.get_disk_usage_maximum).to eq(2 * 447)
    end
  end
end
