require 'spec_helper'

describe ResultPublication do
  it "should be respond to concealed?" do
    result_publication = FactoryGirl.build(:result_publication)

    result_publication.should respond_to(:concealed?)
  end

  it "should be able to tell if the results are concealed" do
    result_publication = FactoryGirl.create(:result_publication, published: true)

    result_publication.concealed?.should be_falsey
    result_publication.published = false

    result_publication.concealed?.should be_truthy
  end

  it "should be able to set published with publish!" do
    result_publication = FactoryGirl.create(:result_publication, published: false)
    result_publication.publish!

    result_publication.reload
    result_publication.published?.should be_truthy
  end

  it "should be able to set published with conceal!" do
    result_publication = FactoryGirl.create(:result_publication, published: true)
    result_publication.conceal!

    result_publication.reload
    result_publication.concealed?.should be_truthy
  end

  it "should be initially concealed" do
    exercise = FactoryGirl.create(:exercise)
    tutorial_group = FactoryGirl.create(:exercise, term: exercise.term)

    exercise.result_publications.each do |result_publication|
      expect(result_publication.published === false).to be_truthy
    end
  end

  it "should be able to fetch result publication for a given exercise and tutorial group" do
    exercise = FactoryGirl.create(:exercise)
    tutorial_group = FactoryGirl.create(:tutorial_group, term: exercise.term)

    ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group).should be_kind_of(ResultPublication)
  end
end
