require 'rails_helper'

RSpec.describe Export do
  subject { FactoryGirl.create(:export) }

  describe 'db columns' do
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:integer) }
    it { is_expected.to have_db_column(:file).of_type(:string) }
    it { is_expected.to have_db_column(:properties).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'behaviours' do
    it { is_expected.to be_a(Polymorphable) }
    it { is_expected.to be_a(SerializedProperties) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:term) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:term) }
  end

  describe 'attributes' do
    it { is_expected.to define_enum_for(:status).with([:pending, :running, :finished, :failed]) }
  end

  describe 'initialization' do
    it 'sets the default status to :pending' do
      expect(subject.status.to_s).to eq("pending")
    end
  end

  describe '#policy_class' do
    it 'is expected to return ExportPolicy' do
      expect(subject.policy_class).to eq(ExportPolicy)
    end
  end

  describe '#perform!' do
    it "raises NotImplementedError" do
      expect do
        subject.perform!
      end.to raise_error(NotImplementedError)
    end
  end

  describe '#perform_export!' do
    it { is_expected.to respond_to(:perform_export!) }

    describe 'with successful #perform!' do
      it 'sets the status to :running then to :finished' do
        allow(subject).to receive(:perform!).and_return(true)
        expect(subject).to receive(:status=).with(:running).once.and_call_original
        expect(subject).to receive(:status=).with(:finished).once.and_call_original

        subject.perform_export!

        expect(subject.status.to_s).to eq("finished")
      end
    end

    describe 'with failing #perform!' do
      it 'raises the error' do
        allow(subject).to receive(:perform!).and_raise("export error")

        expect do
          subject.perform_export!
        end.to raise_error("export error")
      end
    end
  end

end
