require 'rails_helper'

RSpec.describe Import::Importer do
  it 'imports successfully', sidekiq: :inline do
    term = FactoryGirl.create :term
    student_import = FactoryGirl.create :import, term: term

    expect {
    expect {
    expect {
          student_import.import
    }.to change(ActionMailer::Base.deliveries, :count).by(8)
    }.to change(TutorialGroup, :count).by(4)
    }.to change(Account, :count).by(8)

    Account.all.each do |account|
      term_registration = TermRegistration.find_by(term: term, account: account, role: 'student')
      expect(term_registration).to be_present
    end
  end
end
