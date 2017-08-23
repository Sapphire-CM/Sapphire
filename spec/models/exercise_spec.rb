require 'rails_helper'

describe Exercise do
  let!(:term) { FactoryGirl.create :term }
  let!(:tutorial_groups) { FactoryGirl.create_list :tutorial_group, 4, term: term }
  subject { FactoryGirl.create :exercise, term: term }

  describe 'validations' do
    context 'validates deadlines properly' do
      it 'is not valid if deadline is missing and late_deadline is present' do
        subject.deadline = nil
        subject.late_deadline = Time.now
        expect(subject).not_to be_valid
      end

      it 'is valid if late_deadline is after deadline' do
        subject.deadline = Time.now
        subject.late_deadline = Time.now + 1.day
        expect(subject).to be_valid
      end

      it 'is not valid if late_deadline is before deadline' do
        subject.deadline = Time.now + 1.day
        subject.late_deadline = Time.now
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'creation' do
    it 'ensures result publications on create' do
      expect(subject.result_publications.count).to eq(4)
    end

    it 'destroys result publications on delete' do
      subject # trigger creation
      expect do
        subject.destroy
      end.to change { ResultPublication.count }.by(-4)
    end
  end

  describe 'methods' do
    describe '#result_publication_for' do
      it 'is able to fetch result publication for a given tutorial group' do
        result_publication = subject.result_publication_for(tutorial_groups[1])

        expect(result_publication).to be_present
        expect(result_publication.tutorial_group).to eq(tutorial_groups[1])
      end
    end

    describe '#result_published_for?' do
      it 'is able to determine result publication status for a given tutorial group' do
        expect(subject.result_published_for? tutorial_groups[1]).to eq(false)
      end
    end


    describe '#starting_points_sum' do
      let!(:rating_groups) {FactoryGirl.create_list(:rating_group, 3, points: 7, exercise: subject) }

      it 'returns the sum of rating group points' do
        expect(subject.starting_points_sum).to eq(21)
      end
    end
  end
end
