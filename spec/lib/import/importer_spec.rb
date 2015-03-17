require 'rails_helper'

RSpec.describe Import::Importer do
  context 'imports successfully' do
    it 'with everything ok', sidekiq: :inline do
      term = FactoryGirl.create :term
      import = FactoryGirl.create :import, term: term

      expect {
      expect {
      expect {
        ImportJob.perform_later import.id
        import.reload
      }.to change(ActionMailer::Base.deliveries, :count).by(8)
      }.to change(TutorialGroup, :count).by(4)
      }.to change(Account, :count).by(8)

      expect(import.import_result.success).to eq(true)
      expect(import.import_result.import_errors.length).to eq(0)

      Account.all.each do |account|
        term_registration = TermRegistration.find_by(term: term, account: account, role: 'student')
        expect(term_registration).to be_present
      end
    end

    it 'with faulty non-matching group regexp', sidekiq: :inline do
      term = FactoryGirl.create :term
      import = FactoryGirl.create :import, term: term, file: prepare_static_test_file('import_data_faulty_group_regexp.csv', open: true)
      import.reload
      import.import_options.update! matching_groups: :both_matches

      expect {
      expect {
      expect {
      expect {
        ImportJob.perform_later import.id
        import.reload
      }.to change(ActionMailer::Base.deliveries, :count).by(7)
      }.to change(TutorialGroup, :count).by(2)
      }.to change(StudentGroup, :count).by(4)
      }.to change(Account, :count).by(7)

      expect(import.import_result.success).to eq(false)
      expect(import.import_result.import_errors.length).to eq(1)

      Account.all.each do |account|
        term_registration = TermRegistration.find_by(term: term, account: account, role: 'student')
        expect(term_registration).to be_present
      end
    end
  end
end
