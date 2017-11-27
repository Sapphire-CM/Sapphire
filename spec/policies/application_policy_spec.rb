require 'rails_helper'

RSpec.describe ApplicationPolicy do
  let(:record) { "string" }
  let(:user) { FactoryGirl.build(:account) }

  subject { described_class.new(user, record) }

  describe 'initialization' do
    it 'assigns user and record' do
      policy = described_class.new(user, record)

      expect(policy.user).to eq(user)
      expect(policy.record).to eq(record)
    end

    it 'raises Pundit::NotAuthorizedError if user is not signed in' do
      expect do
        described_class.new(nil, record)
      end.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe 'default permissions' do
    it { is_expected.not_to permit_authorization(:index) }
    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:new) }
    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.not_to permit_authorization(:edit) }
    it { is_expected.not_to permit_authorization(:update) }
    it { is_expected.not_to permit_authorization(:destroy) }
  end

  describe 'methods' do
    describe '.policy_record_with' do
      class ObjectPolicy < described_class; end

      it 'returns a policy record with given options' do
        record = described_class.policy_record_with(foo: :bar)

        expect(record.foo).to eq(:bar)
      end

      it 'sets #policy_class to the current policy' do
        expect(described_class.policy_record_with({}).policy_class).to eq(described_class)
        expect(ObjectPolicy.policy_record_with({}).policy_class).to eq(ObjectPolicy)
      end
    end

    describe '#new?' do
      it 'aliases #create?' do
        expect(subject).to receive(:create?).and_return(true, false)

        expect(subject.new?).to be_truthy
        expect(subject.new?).to be_falsey
      end
    end

    describe '#edit?' do
      it 'aliases #update?' do
        expect(subject).to receive(:update?).and_return(true, false)

        expect(subject.edit?).to be_truthy
        expect(subject.edit?).to be_falsey
      end
    end

    describe '#scope' do
      it 'calls Pundit.policy_scope!' do
        expect(Pundit).to receive(:policy_scope!).with(user, Object).and_return(nil)

        subject.scope
      end
    end
  end

  describe '::Scope' do
    describe 'initializtion' do
      it 'assigns user and scope' do
        scope = described_class::Scope.new(user, :scope)
        expect(scope.user).to eq(user)
        expect(scope.scope).to eq(:scope)
      end
    end

    describe '#resolve' do
      it 'returns the scope' do
        scope = described_class::Scope.new(user, :scope)

        expect(scope.resolve).to eq(:scope)
      end
    end
  end
end