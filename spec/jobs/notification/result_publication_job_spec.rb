require 'rails_helper'

RSpec.describe Notification::ResultPublicationJob, type: :job do

  describe '#perform' do
    let(:term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:exercise) { FactoryGirl.create(:exercise, term: term) }

    let!(:student_term_registrations) { FactoryGirl.create_list(:term_registration, 3, :student, term: term, tutorial_group: tutorial_group) }
    let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }
    let!(:result_publication) { exercise.result_publications.first }

    it 'notifies students about the result publication' do
      student_term_registrations.each do |term_registration|
        expect(NotificationMailer).to receive(:result_publication_notification).with(term_registration, result_publication).and_call_original
      end

      subject.perform(result_publication)
    end
  end

end
