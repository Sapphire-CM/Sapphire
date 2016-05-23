require 'rails_helper'
require 'zip'

RSpec.describe Exports::ExcelSpreadsheetExport, sidekiq: :inline do
  let!(:term) { FactoryGirl.create :term }
  let!(:exercises) { FactoryGirl.create_list :exercise, 4, :with_ratings }
  let!(:tutorial_groups) { FactoryGirl.create_list :tutorial_group, 4, term: term }
  let(:export) { FactoryGirl.create :excel_spreadsheet_export, term: term }

  describe '#perform_export!' do
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

  describe '#set_default_values!' do
    it 'sets default values if none are present' do
      expect(subject.summary).to eq(nil)
      expect(subject.exercises).to eq(nil)
      expect(subject.student_overview).to eq(nil)

      subject.set_default_values!

      expect(subject.summary).to eq('1')
      expect(subject.exercises).to eq('1')
      expect(subject.student_overview).to eq('1')
    end

    it 'does not overwrite existing values' do
      subject.summary = '0'
      subject.exercises = '0'
      subject.student_overview = '0'

      subject.set_default_values!

      expect(subject.summary).to eq('0')
      expect(subject.exercises).to eq('0')
      expect(subject.student_overview).to eq('0')
    end
  end
end
