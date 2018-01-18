require 'rails_helper'

RSpec.describe ImportError do
  describe 'db columns' do
    it { is_expected.to have_db_column(:row).of_type(:string) }
    it { is_expected.to have_db_column(:entry).of_type(:string) }
    it { is_expected.to have_db_column(:message).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:import_result) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:import_result) }
    it { is_expected.to validate_presence_of(:row) }
    it { is_expected.to validate_presence_of(:entry) }
    it { is_expected.to validate_presence_of(:message) }
  end
end