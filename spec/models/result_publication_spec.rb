require 'rails_helper'

describe ResultPublication do
  it 'is respond to concealed?' do
    result_publication = FactoryGirl.build(:result_publication)

    expect(result_publication).to respond_to(:concealed?)
  end

  it 'is able to tell if the results are concealed' do
    result_publication = FactoryGirl.create(:result_publication, published: true)

    expect(result_publication.concealed?).to be_falsey
    result_publication.published = false

    expect(result_publication.concealed?).to be_truthy
  end

  it 'is able to set published with publish!' do
    result_publication = FactoryGirl.create(:result_publication, published: false)
    result_publication.publish!

    result_publication.reload
    expect(result_publication.published?).to be_truthy
  end

  it 'is able to set published with conceal!' do
    result_publication = FactoryGirl.create(:result_publication, published: true)
    result_publication.conceal!

    result_publication.reload
    expect(result_publication.concealed?).to be_truthy
  end

  it 'is initially concealed' do
    exercise = FactoryGirl.create(:exercise)
    tutorial_group = FactoryGirl.create(:exercise, term: exercise.term)

    exercise.result_publications.each do |result_publication|
      expect(result_publication.published === false).to be_truthy
    end
  end

  it 'is able to fetch result publication for a given exercise and tutorial group' do
    exercise = FactoryGirl.create(:exercise)
    tutorial_group = FactoryGirl.create(:tutorial_group, term: exercise.term)

    expect(ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group)).to be_kind_of(ResultPublication)
  end
end
