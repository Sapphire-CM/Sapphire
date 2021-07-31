require 'rails_helper'

RSpec.describe Notification::ExportFinishedJob, type: :job do

  describe '#perform' do
    let(:term) { FactoryBot.create(:term) }
    let!(:export) { FactoryBot.create(:export, term: term) }

    let!(:lecturer_term_registrations) { FactoryBot.create_list(:term_registration, 3, :lecturer, term: term) }
    let!(:tutor_term_registration) { FactoryBot.create(:term_registration, :tutor, term: term) }
    let!(:student_term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
    let!(:other_lecturer_term_registrations) { FactoryBot.create_list(:term_registration, 3, :lecturer) }

    let(:lecturers) { lecturer_term_registrations.map(&:account) }
    let(:other_lecturers) { other_lecturer_term_registrations.map(&:account) }
    let(:admins) { FactoryBot.create_list(:account, 3, :admin) }

    let(:accounts) { admins + lecturers }

    it 'notifies admins and lecturers of given term about the finished export' do
      accounts.each do |account|
        expect(NotificationMailer).to receive(:export_finished_notification).with(account, export).and_call_original
      end

      subject.perform(export)
    end

    it 'does not send two notifications if a lecturer is an admin' do
      lecturers.first.update(admin: true)

      accounts.each do |account|
        expect(NotificationMailer).to receive(:export_finished_notification).with(account, export).and_call_original.once
      end

      subject.perform(export)
    end
  end

end
