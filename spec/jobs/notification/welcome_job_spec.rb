require 'rails_helper'

RSpec.describe Notification::WelcomeJob, type: :job do
  describe '#perform' do
    let(:term_registration) { FactoryGirl.create(:term_registration, :student, welcomed_at: nil) }
    let(:term) { term_registration.term }
    let(:account) { term_registration.account }

    let(:now) { Time.now }
    it 'sends a welcome notification if the student is notified the first time' do
      expect(NotificationMailer).to receive(:welcome_notification).with(account, term).and_call_original

      subject.perform(term_registration)
    end

    it 'sends a welcome back notification if the student is notified the first time' do
      FactoryGirl.create(:term_registration, :student, account: account)

      expect(NotificationMailer).to receive(:welcome_back_notification).with(account, term).and_call_original
      subject.perform(term_registration)
    end

    it 'sets welcomed_at of term registration' do
      Timecop.freeze(now) do
        subject.perform(term_registration)

        expect(term_registration.welcomed_at).to be_within(1.second).of(now)
      end
    end
  end
end
