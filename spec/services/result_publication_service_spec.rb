require 'rails_helper'

RSpec.describe ResultPublicationService do
  let(:term) { create(:term) }
  let!(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let!(:tutorial_groups) { FactoryGirl.create_list(:tutorial_group, 4, term: term) }
  let(:account) { FactoryGirl.create(:account, :admin) }

  subject { ResultPublicationService.new(account, exercise) }

  describe 'initialization' do
    it 'takes an account and an exercise as arguments' do
      expect(subject.account).to eq(account)
      expect(subject.exercise).to eq(exercise)
    end
  end

  describe '#publish!' do
    let(:result_publication) { ResultPublication.for(exercise: exercise, tutorial_group: tutorial_groups.first) }

    it 'publishes given result_publication, creates an event and sends notifications' do
      expect(result_publication.published?).to be_falsey
      expect(Notification::ResultPublicationJob).to receive(:perform_later).with(result_publication).and_return(true)

      expect do
        subject.publish!(result_publication)
      end.to change(Events::ResultPublication::Published, :count).by(1)

      expect(result_publication.published?).to be_truthy
    end

    it 'does nothing when result publication is already published' do
      result_publication.update(published: true)

      expect(result_publication.published?).to be_truthy
      expect(Notification::ResultPublicationJob).not_to receive(:perform_later).with(result_publication)

      expect do
        subject.publish!(result_publication)
      end.not_to change(Events::ResultPublication::Published, :count)

      expect(result_publication.published?).to be_truthy
    end

    it 'raises an error when exercises don\'t match' do
      expect do
        subject.publish!(create(:result_publication))
      end.to raise_error ArgumentError
    end
  end

  describe '#conceal!' do
    let(:result_publication) { ResultPublication.for(exercise: exercise, tutorial_group: tutorial_groups.first) }

    before(:each) do
      result_publication.update(published: true)
    end

    it 'conceals given result_publication, creates an event but does not send emails' do
      expect(result_publication.concealed?).to be_falsey

      expect(Notification::ResultPublicationJob).not_to receive(:perform_later).with(result_publication)

      expect do
        subject.conceal!(result_publication)
      end.to change(Events::ResultPublication::Concealed, :count).by(1)

      expect(result_publication.concealed?).to be_truthy
    end

    it 'does nothing when result publication is already concealed' do
      result_publication.update(published: false)

      expect(result_publication.concealed?).to be_truthy
      expect do
        subject.conceal!(result_publication)
      end.not_to change(Events::ResultPublication::Concealed, :count)

      expect(result_publication.concealed?).to be_truthy
    end

    it 'raises an error when exercises don\'t match' do
      expect do
        subject.conceal!(create(:result_publication))
      end.to raise_error ArgumentError
    end
  end

  describe '#publish_all!' do
    it 'calls #publish! with all result_publications of given exercise' do
      exercise.result_publications.each do |result_publication|
        expect(subject).to receive(:publish!).with(result_publication).and_return true
      end

      subject.publish_all!
    end
  end

  describe '#conceal_all!' do
    it 'calls #conceal! with all result_publications of given exercise' do
      exercise.result_publications.each do |result_publication|
        expect(subject).to receive(:conceal!).with(result_publication).and_return true
      end

      subject.conceal_all!
    end
  end
end
