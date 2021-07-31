require 'rails_helper'
require 'zip'

RSpec.describe Exports::GradingExport do
  let!(:term) { FactoryBot.create :term }
  let!(:exercises) { FactoryBot.create_list :exercise, 4, :with_ratings }
  let!(:tutorial_groups) { FactoryBot.create_list :tutorial_group, 4, term: term }
  let(:export) { FactoryBot.create :grading_export, term: term }

  describe 'initialization' do
    it 'calls #set_default_values!' do
      expect_any_instance_of(described_class).to receive(:set_default_values)

      described_class.new
    end
  end

  describe '#perform_export!' do
    it 'generates a export file' do
      expect(export.reload.file).to be_blank
      
      export.perform_export!
      
      expect(export.reload.file).to be_present
      expect(export.status.to_sym).to eq(:finished)
      
      Zip::File.open(export.file.to_s) do |zip_file|
        expect(zip_file.count).to eq(tutorial_groups.count + 1)
      end
    end
  end

  describe '#set_default_values!' do
    it 'sets default values if none are present' do
      subject.summary = nil
      subject.exercises = nil
      subject.student_overview = nil

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
