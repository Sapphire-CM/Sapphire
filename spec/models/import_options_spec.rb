require 'rails_helper'

RSpec.describe ImportOptions do
  describe 'db columns' do
    it { is_expected.to have_db_column(:matching_groups).of_type(:integer) }
    it { is_expected.to have_db_column(:tutorial_groups_regexp).of_type(:string) }
    it { is_expected.to have_db_column(:student_groups_regexp).of_type(:string) }
    it { is_expected.to have_db_column(:headers_on_first_line).of_type(:boolean).with_options(default: true) }
    it { is_expected.to have_db_column(:column_separator).of_type(:string) }
    it { is_expected.to have_db_column(:quote_char).of_type(:string) }
    it { is_expected.to have_db_column(:decimal_separator).of_type(:string) }
    it { is_expected.to have_db_column(:thousands_separator).of_type(:string) }
    it { is_expected.to have_db_column(:send_welcome_notifications).of_type(:boolean).with_options(default: true, null: false) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:import) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:import) }
    it { is_expected.to validate_uniqueness_of(:import_id) }

    it { is_expected.to validate_length_of(:quote_char).is_equal_to(1) }
    it { is_expected.to validate_length_of(:decimal_separator).is_equal_to(1) }
    it { is_expected.to validate_length_of(:thousands_separator).is_equal_to(1) }
    it { is_expected.to validate_length_of(:column_separator).is_equal_to(1) }
  end

  describe 'attributes' do
    it { is_expected.to define_enum_for(:matching_groups).with([:first_match, :both_matches]) }
  end

  describe 'initialization' do
    it 'sets initial values' do
      subject = described_class.new

      expect(subject.first_match?).to be_truthy
      expect(subject.tutorial_groups_regexp).to eq('\A(?<tutorial>T[\d]+)\z')
      expect(subject.student_groups_regexp).to eq('\AG(?<tutorial>[\d]+)-(?<student>[\d]+)i?\z')
      expect(subject.column_separator).to eq(';')
      expect(subject.quote_char).to eq('"')
      expect(subject.decimal_separator).to eq(',')
      expect(subject.thousands_separator).to eq('.')
      expect(subject.headers_on_first_line).to be_truthy
      expect(subject.send_welcome_notifications).to be_truthy
    end
  end
end