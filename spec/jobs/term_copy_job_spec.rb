require 'rails_helper'

RSpec.describe TermCopyJob do
  describe '#perform' do
    let(:term) { FactoryGirl.create(:term) }
    let(:source_term) { FactoryGirl.create(:term, course: term.course) }
    let(:options) { {option: true} }
    let(:term_copy_service) { instance_double(TermCopyService) }
    let(:other_course) { FactoryGirl.create(:course) }

    it 'delegates to the TermCopyService' do
      expect(TermCopyService).to receive(:new).with(term, source_term, options).and_return(term_copy_service)
      expect(term_copy_service).to receive(:perform!)

      subject.perform(term.id, source_term.id, options)
    end

    it 'raises ActiveRecord::RecordNotFound if term id is unkown' do
      expect do
        subject.perform(-1, source_term.id, options)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises ActiveRecord::RecordNotFound if source_term is of another course' do
      source_term.update(course: other_course)

      expect do
        subject.perform(term.id, source_term.id, options)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end