require 'rails_helper'

describe Exercise do
  let(:course) { create(:course) }
  let(:term) { create(:term, course: course) }

  it 'is able to set student uploads' do
    exercise = FactoryGirl.create(:exercise, allow_student_uploads: true)
    expect(exercise.allow_student_uploads?).to be_truthy

    exercise = FactoryGirl.create(:exercise, allow_student_uploads: false)
    expect(exercise.allow_student_uploads?).to be_falsey
  end

  it 'ensures result publications on create' do
    FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    expect(exercise.result_publications.count).to eq(4)
  end

  it 'destroys result publications on delete' do
    FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    expect do
      exercise.destroy
    end.to change { ResultPublication.count }.by(-4)
  end

  it 'is able to fetch result publication for a given tutorial group' do
    tutorial_groups = FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    result_publication = exercise.result_publication_for(tutorial_groups[1])

    expect(result_publication).to be_present
    expect(result_publication.tutorial_group).to eq(tutorial_groups[1])
  end

  it 'is able to determine result publication status for a given tutorial group' do
    tutorial_groups = FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    expect(exercise.result_published_for? tutorial_groups[1]).to eq(false)
  end
end
