require 'rails_helper'

describe TutorialGroup do
  it { is_expected.to have_many :term_registrations }

  let(:course) { create(:course) }
  let(:term) { create(:term, course: course) }

  it 'ensures result publications on create' do
    FactoryGirl.create_list(:exercise, 4, term: term)
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    expect(tutorial_group.result_publications.count).to eq(4)
  end

  it 'destroys result publications on delete' do
    FactoryGirl.create_list(:exercise, 4, term: term)
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    expect do
      tutorial_group.destroy
    end.to change { ResultPublication.count }.by(-4)
  end
end
