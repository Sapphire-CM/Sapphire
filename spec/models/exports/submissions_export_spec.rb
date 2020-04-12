require 'rails_helper'
require 'zip'

RSpec.describe Exports::SubmissionsExport do
  describe '#set_default_values!' do
    it 'sets default values' do
      expect(subject.base_path).to eq(nil)
      expect(subject.solitary_path).to eq(nil)
      expect(subject.group_path).to eq(nil)
      expect(subject.include_solitary_submissions).to eq(nil)
      expect(subject.include_group_submissions).to eq(nil)

      subject.set_default_values!

      expect(subject.base_path).not_to be_blank
      expect(subject.solitary_path).not_to be_blank
      expect(subject.group_path).not_to be_blank
      expect(subject.include_solitary_submissions).to eq('1')
      expect(subject.include_group_submissions).to eq('1')
    end

    it 'does not change existing values' do
      subject.base_path = 'base_path'
      subject.solitary_path = 'solitary_path'
      subject.group_path = 'group_path'
      subject.include_solitary_submissions = '0'
      subject.include_group_submissions = '0'

      subject.set_default_values!

      expect(subject.base_path).to eq('base_path')
      expect(subject.solitary_path).to eq('solitary_path')
      expect(subject.group_path).to eq('group_path')
      expect(subject.include_solitary_submissions).to eq('0')
      expect(subject.include_group_submissions).to eq('0')
    end
  end
end
