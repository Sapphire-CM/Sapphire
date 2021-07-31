require 'rails_helper'

RSpec.describe ImportResult do
  let(:import) { FactoryBot.create(:import) }
  let(:updated_attributes) { {success: true, total_rows: 10, processed_rows: 3, imported_students: 4, imported_tutorial_groups: 5, imported_term_registrations: 6, imported_student_groups: 7} }
  let(:default_attributes) { {success: false, total_rows: 0, processed_rows: 0, imported_students: 0, imported_tutorial_groups: 0, imported_term_registrations: 0, imported_student_groups: 0} }

  describe 'db columns' do
    it { is_expected.to have_db_column(:success).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:encoding_error).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:parsing_error).of_type(:boolean).with_options(default: false, null: false) }

    it { is_expected.to have_db_column(:total_rows).of_type(:integer) }
    it { is_expected.to have_db_column(:processed_rows).of_type(:integer) }
    it { is_expected.to have_db_column(:imported_students).of_type(:integer) }
    it { is_expected.to have_db_column(:imported_tutorial_groups).of_type(:integer) }
    it { is_expected.to have_db_column(:imported_term_registrations).of_type(:integer) }
    it { is_expected.to have_db_column(:imported_student_groups).of_type(:integer) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:import) }
    it { is_expected.to have_many(:import_errors).dependent(:destroy) }
  end

  describe 'validations' do
    subject { import.import_result }

    it { is_expected.to validate_presence_of(:import) }
    it { is_expected.to validate_uniqueness_of(:import_id) }

    it { is_expected.to validate_numericality_of(:total_rows).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:processed_rows).is_greater_than_or_equal_to(0) }
  end

  describe 'initialization' do
    it 'sets initial values' do
      subject = described_class.new

      expect(subject.success).to be_falsey
      expect(subject.total_rows).to eq(0)
      expect(subject.processed_rows).to eq(0)
      expect(subject.imported_students).to eq(0)
      expect(subject.imported_tutorial_groups).to eq(0)
      expect(subject.imported_term_registrations).to eq(0)
      expect(subject.imported_student_groups).to eq(0)
    end

    it 'does not overwrite options when loading from DB' do
      subject = import.import_result
      subject.update(updated_attributes)

      reloaded_subject = described_class.find(subject.id)

      updated_attributes.each do |key, value|
        expect(reloaded_subject.send(key)).to eq(value)
      end
    end
  end

  describe 'methods' do
    describe '#reset!' do
      let(:import) { FactoryBot.create(:import, :with_errors) }
      subject { import.import_result }

      it 'sets default attributes' do
        subject.update(updated_attributes)
        subject.reset!

        default_attributes.each do |key, value|
          expect(subject.send(key)).to eq(value)
        end
      end

      it 'destroys all import errors' do

        expect(subject.import_errors.reload.count).not_to eq(0)
        subject.reset!
        expect(subject.import_errors.reload.count).to eq(0)
      end
    end

    describe '#progress' do
      it 'returns the progress in percent' do
        subject.assign_attributes(processed_rows: 0, total_rows: 10)
        expect(subject.progress).to eq(0)

        subject.assign_attributes(processed_rows: 5, total_rows: 10)
        expect(subject.progress).to eq(50)

        subject.assign_attributes(processed_rows: 15, total_rows: 15)
        expect(subject.progress).to eq(100)
      end

      it 'does not raise an error if no rows have been processed' do
        subject.assign_attributes(processed_rows: 0, total_rows: 0)

        expect do
          expect(subject.progress).to eq(0)
        end.not_to raise_error
      end
    end
  end
end