require 'rails_helper'
require 'zip'

RSpec.describe Exports::ExcelSpreadsheetExport, sidekiq: :inline do
  let!(:term) { FactoryGirl.create :term }
  let!(:exercises) { FactoryGirl.create_list :exercise, 4, :with_ratings }
  let!(:tutorial_groups) { FactoryGirl.create_list :tutorial_group, 4, term: term }
  let(:export) { FactoryGirl.create :excel_spreadsheet_export, term: term }

  it 'generates a export file' do
    expect do
      export.reload
      export.perform_export!
      export.reload
    end.to change(export.file, :to_s)

    expect(export.status.to_sym).to eq(:finished)

    Zip::File.open(export.file.to_s) do |zip_file|
      expect(zip_file.count).to eq(tutorial_groups.count + 1)
    end
  end
end
