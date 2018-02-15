require 'rails_helper'

RSpec.describe Notification::SendPendingWelcomesJob, type: :job do
  describe '#perform' do
    let(:term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:welcomed_student_term_registrations) { FactoryGirl.create_list(:term_registration, 3, :student, tutorial_group: tutorial_group, term: term, welcomed_at: Time.now) }
    let!(:not_welcomed_student_term_registrations) { FactoryGirl.create_list(:term_registration, 3, :student, tutorial_group: tutorial_group, term: term, welcomed_at: nil) }
    let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, tutorial_group: tutorial_group, term: term) }
    let!(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term) }

    it 'sends pending welcome notifications to students' do
      not_welcomed_student_term_registrations.each do |term_registration|
        expect(Notification::WelcomeJob).to receive(:perform_now).with(term_registration)
      end

      subject.perform(term)
    end
  end
end
