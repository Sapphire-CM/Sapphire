require 'rails_helper'

describe TutorialGroup do
  it { is_expected.to have_many :term_registrations }

  let(:course) { create(:course) }
  let(:term) { create(:term, course: course) }

  describe 'callbacks' do
    it 'ensures result publications on create' do
      FactoryGirl.create_list(:exercise, 4, term: term)
      term.reload

      tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

      expect(tutorial_group.result_publications.count).to eq(4)
    end

    it 'destroys result publications on delete' do
      FactoryGirl.create_list(:exercise, 4, term: term)
      term.reload

      tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

      expect do
        tutorial_group.destroy
      end.to change { ResultPublication.count }.by(-4)
    end

    it 'destroys tutor_term_registrations on delete' do
      tutorial_group = FactoryGirl.create(:tutorial_group, :with_tutor, term: term)

      expect(tutorial_group.tutor_term_registrations.count).to eq(1)

      expect do
        tutorial_group.destroy
      end.to change(TermRegistration, :count).by(-1)
    end

    it 'destroys tutor_term_registrations on delete' do
      tutorial_group = FactoryGirl.create(:tutorial_group, :with_students, students_count: 3, term: term)

      expect(tutorial_group.student_term_registrations.count).to eq(3)

      expect do
        tutorial_group.destroy
      end.to change(TermRegistration, :count).by(-3)
    end
  end

  describe 'scoping' do
    describe '.ordered_by_title' do
      it 'returns submissions ordered by title' do
        expect(described_class).to receive(:order).with(:title)
        described_class.ordered_by_title
      end
    end
  end
end
