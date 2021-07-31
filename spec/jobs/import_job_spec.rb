require 'rails_helper'

RSpec.describe ImportJob do

  describe '#perform' do
    let(:import) { FactoryBot.create(:import) }
    let(:import_service) { instance_double(ImportService) }

    it 'fetches the given import and passes it on to the import service' do
      expect(ImportService).to receive(:new).with(import).and_return(import_service)
      expect(import_service).to receive(:perform!)

      subject.perform(import.id)
    end
  end
end