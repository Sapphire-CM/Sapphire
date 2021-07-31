require 'rails_helper'

RSpec.describe Notification::SendPendingWelcomesJob, type: :job do
  describe '#perform' do
    let(:term) { FactoryBot.create(:term) }
    let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
    let!(:welcomed_student_term_registrations) { FactoryBot.create_list(:term_registration, 3, :student, tutorial_group: tutorial_group, term: term, welcomed_at: Time.now) }
    let!(:not_welcomed_student_term_registrations) { FactoryBot.create_list(:term_registration, 3, :student, tutorial_group: tutorial_group, term: term, welcomed_at: nil) }
    let!(:tutor_term_registration) { FactoryBot.create(:term_registration, :tutor, tutorial_group: tutorial_group, term: term) }
    let!(:lecturer_term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term) }

    it 'sends pending welcome notifications to students' do
      not_welcomed_student_term_registrations.each do |term_registration|
        expect(Notification::WelcomeJob).to receive(:perform_now).with(term_registration)
      end

      subject.perform(term)
    end
  end
end
