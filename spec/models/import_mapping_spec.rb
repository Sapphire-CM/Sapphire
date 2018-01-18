require 'rails_helper'

RSpec.describe ImportMapping do
  describe 'db columns' do
    it { is_expected.to have_db_column(:group).of_type(:integer) }
    it { is_expected.to have_db_column(:email).of_type(:integer) }
    it { is_expected.to have_db_column(:forename).of_type(:integer) }
    it { is_expected.to have_db_column(:surname).of_type(:integer) }
    it { is_expected.to have_db_column(:matriculation_number).of_type(:integer) }
    it { is_expected.to have_db_column(:comment).of_type(:integer) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:import) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:import) }
    it { is_expected.to validate_uniqueness_of(:import_id) }
  end

  describe 'constants' do
    describe '::IMPORTABLE' do
      let(:importable_options) { [:group, :email, :forename, :surname, :matriculation_number, :comment] }

      it 'matches importable options' do
        expect(described_class::IMPORTABLE).to match_array(importable_options)
      end
    end
  end
end