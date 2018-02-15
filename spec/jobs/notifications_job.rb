require 'rails_helper'

RSpec.describe NotificationJob do
  describe 'methods' do
    describe '.result_publication_notifications' do
      let(:result_publication) { instance_double(ResultPublication, id: 42) }

      it 'delegates to .perform_later' do
        expect(described_class).to receive(:perform_later).with("result_publication", 42)

        described_class.result_publication_notifications(result_publication)
      end
    end

    describe '.export_finished_notifications' do
      let(:export) { instance_double(Export, id: 42) }

      it 'delegates to .perform_later' do
        expect(described_class).to receive(:perform_later).with("export_finished", 42)

        described_class.export_finished_notifications(export)
      end
    end

    describe '.welcome_notifications_for_term' do
      let(:term) { instance_double(Term) }

      it 'delegates to .perform_later' do
        expect(described_class).to receive(:perform_later).with("welcome_for_term", term)

        described_class.welcome_notifications_for_term(term)
      end
    end

    describe '.welcome_notification' do
      let(:term_registration) { instance_double(TermRegistration) }

      it 'delegates to .perform_later' do
        expect(described_class).to receive(:perform_later).with("welcome", term_registration)

        described_class.welcome_notification(term_registration)
      end
    end

    describe '#perform' do
      describe 'result_publication' do
        let(:term) { FactoryGirl.create(:term) }
        let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
        let!(:term_registrations) { FactoryGirl.create_list(:term_registration, 3, :student, term: term, tutorial_group: tutorial_group) }
        let(:exercise) { FactoryGirl.create(:exercise, term: term) }
        let!(:result_publication) { exercise.result_publications.first }

        it 'notifies students about the result publication' do
          term_registrations.each do |term_registration|
            expect(NotificationMailer).to receive(:result_publication_notification).with(term_registration, result_publication).and_call_original
          end

          subject.perform("result_publication", result_publication.id)
        end
      end

      describe 'export_finished' do
        let(:term) { FactoryGirl.create(:term) }
        let!(:export) { FactoryGirl.create(:export, term: term) }

        let!(:lecturer_term_registrations) { FactoryGirl.create_list(:term_registration, 3, :lecturer, term: term) }
        let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term) }
        let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
        let!(:other_lecturer_term_registrations) { FactoryGirl.create_list(:term_registration, 3, :lecturer) }

        let(:lecturers) { lecturer_term_registrations.map(&:account) }
        let(:other_lecturers) { other_lecturer_term_registrations.map(&:account) }
        let(:admins) { FactoryGirl.create_list(:account, 3, :admin) }

        let(:accounts) { admins + lecturers }

        it 'notifies admins and lecturers of given term about the finished export' do
          accounts.each do |account|
            expect(NotificationMailer).to receive(:export_finished_notification).with(account, export).and_call_original
          end

          subject.perform("export_finished", export.id)
        end

        it 'does not send two notifications if a lecturer is an admin' do
          lecturers.first.update(admin: true)

          accounts.each do |account|
            expect(NotificationMailer).to receive(:export_finished_notification).with(account, export).and_call_original.once
          end

          subject.perform("export_finished", export.id)
        end
      end

      describe 'welcome' do
        let(:term_registration) { FactoryGirl.create(:term_registration, :student) }
        let(:term) { term_registration.term }
        let(:account) { term_registration.account }

        it 'sends a welcome notification if the student is notified the first time' do
          expect(NotificationMailer).to receive(:welcome_notification).with(account, term).and_call_original

          subject.perform("welcome", term_registration)
        end

        it 'sends a welcome back notification if the student is notified the first time' do
          FactoryGirl.create(:term_registration, :student, account: account)

          expect(NotificationMailer).to receive(:welcome_back_notification).with(account, term).and_call_original

          subject.perform("welcome", term_registration)
        end
      end
    end
  end
end