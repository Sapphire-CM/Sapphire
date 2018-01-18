require 'rails_helper'

RSpec.describe Import do
  describe 'db columns' do
    it { is_expected.to have_db_column(:file).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:integer) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:term) }
    it { is_expected.to have_one(:import_options).inverse_of(:import).dependent(:destroy) }
    it { is_expected.to have_one(:import_mapping).inverse_of(:import).dependent(:destroy) }
    it { is_expected.to have_one(:import_result).inverse_of(:import).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:term) }
    it { is_expected.to validate_presence_of(:file) }
  end

  describe 'attributes' do
    it { is_expected.to define_enum_for(:status).with([:pending, :running, :finished, :failed]) }
    it { is_expected.to accept_nested_attributes_for(:import_options).update_only(true) }
    it { is_expected.to accept_nested_attributes_for(:import_mapping).update_only(true) }
  end

  describe 'initialization' do
    it "sets the status to :pending if it is blank" do
      subject = described_class.new(status: nil)

      expect(subject.pending?).to be_truthy
    end

    pending "creates import_options"
  end
end