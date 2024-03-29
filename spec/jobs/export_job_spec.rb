require 'rails_helper'

RSpec.describe ExportJob do
  describe '#perform' do
    let(:export) { FactoryBot.create(:export) }

    it 'calls #perform! on export' do
      expect(export).to receive(:perform_export!)

      subject.perform(export)
    end

    it 'notifies admins and lecturers after export is finished' do
      allow(export).to receive(:perform_export!).and_return(true)
      expect(Notification::ExportFinishedJob).to receive(:perform_later).with(export)

      subject.perform(export)
    end
  end
end