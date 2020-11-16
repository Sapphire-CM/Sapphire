require 'rails_helper'

RSpec.describe SystemDiskStatistics do
  let!(:stats) {SystemDiskStatistics.new}

  describe '#disk_used' do
    it 'gets the used disk space' do
      expect(stats.disk_used).not_to eq(0)
    end
  end

  describe '#disk_used_percentage' do
    it 'gets the used disk space percentage' do
      expect(stats.disk_used_percentage).not_to eq(0)
    end
  end

  describe '#disk_available' do
    it 'gets the available disk space' do
      expect(stats.disk_available).not_to eq(0)
    end
  end
end
