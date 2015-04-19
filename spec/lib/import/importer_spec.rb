require 'rails_helper'

RSpec.describe Import::Importer do
  context 'imports successfully' do
    { true: 8, false: 0 }.each do |send_welcome_notifications, emails_delivered|
      it "everything ok - send_welcome_notifications: #{send_welcome_notifications}", sidekiq: :inline do
        term = FactoryGirl.create :term
        import = FactoryGirl.create :import, term: term
        import.reload
        import.import_options.update! send_welcome_notifications: (send_welcome_notifications == :true)

        expect do
          expect do
            expect do
              ImportJob.perform_later import.id
              import.reload
            end.to change(ActionMailer::Base.deliveries, :count).by(emails_delivered)
          end.to change(TutorialGroup, :count).by(4)
        end.to change(Account, :count).by(8)

        expect(import.import_result.success).to eq(true)
        expect(import.import_result.import_errors).to be_empty

        Account.all.each do |account|
          term_registration = TermRegistration.find_by(term: term, account: account, role: 'student')
          expect(term_registration).to be_present
        end
      end
    end

    it 'with faulty non-matching group regexp', sidekiq: :inline do
      term = FactoryGirl.create :term
      import = FactoryGirl.create :import, term: term, file: prepare_static_test_file('import_data_faulty_group_regexp.csv', open: true)
      import.reload
      import.import_options.update! matching_groups: :both_matches

      expect do
        expect do
          expect do
            expect do
              ImportJob.perform_later import.id
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
