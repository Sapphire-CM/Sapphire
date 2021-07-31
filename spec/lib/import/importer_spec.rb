require 'rails_helper'

RSpec.describe Import::Importer do

  context 'imports successfully' do
    def basic_import_test(new_accounts: 8, new_tutorial_groups: 4, send_welcome_notifications: true, emails_delivered: 8)
      term = FactoryBot.create :term
      import = FactoryBot.create :import, term: term
      import.reload
      import.import_options.update! send_welcome_notifications: send_welcome_notifications

      expect do
        expect do
          expect do
            perform_enqueued_jobs do
              ImportJob.perform_later import.id
            end
            import.reload

            import.import_result.inspect
            import.import_result.import_errors.inspect
          end.to change(ActionMailer::Base.deliveries, :count).by(emails_delivered)
        end.to change(TutorialGroup, :count).by(new_tutorial_groups)
      end.to change(Account, :count).by(new_accounts)

      expect(import.import_result.success).to eq(true)
      expect(import.import_result.import_errors).to be_empty

      Account.all.each do |account|
        term_registration = TermRegistration.find_by(term: term, account: account, role: 'student')
        expect(term_registration).to be_present
      end
    end

    it 'everything ok - standard' do
      basic_import_test
    end

    it 'everything ok - no welcome_notifications' do
      basic_import_test send_welcome_notifications: false, emails_delivered: 0
    end

    it 'everything ok - with existing account with email' do
      FactoryBot.create :account, email: 'owinkler@student.tugraz.at'
      basic_import_test new_accounts: 7
    end

    it 'everything ok - with existing account with matriculation_number' do
      FactoryBot.create :account, matriculation_number: '1434949'
      basic_import_test new_accounts: 7
    end

    it 'with faulty non-matching group regexp' do
      term = FactoryBot.create :term
      import = FactoryBot.create :import, term: term, file: prepare_static_test_file('import_data_faulty_group_regexp.csv', open: true)
      import.reload
      import.import_options.update! matching_groups: :both_matches

      expect do
        expect do
          expect do
            expect do
              perform_enqueued_jobs do
                ImportJob.perform_later import.id
              end

              import.reload
            end.to change(ActionMailer::Base.deliveries, :count).by(7)
          end.to change(TutorialGroup, :count).by(2)
        end.to change(StudentGroup, :count).by(4)
      end.to change(Account, :count).by(7)

      expect(import.import_result.success).to eq(false)
      expect(import.import_result.import_errors.length).to eq(1)

      Account.all.each do |account|
        term_registration = TermRegistration.find_by(term: term, account: account, role: 'student')
        expect(term_registration).to be_present
      end
    end
  end
end
