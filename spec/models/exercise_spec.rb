require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Exercise do
  let(:course) { create(:course) }
  let(:term) { create(:term, course: course)}

  it "should be able to set student uploads" do
    exercise = FactoryGirl.create(:exercise, allow_student_uploads: true)
    exercise.allow_student_uploads?.should be_true

    exercise = FactoryGirl.create(:exercise, allow_student_uploads: false)
    exercise.allow_student_uploads?.should be_false
  end

  it "should ensure result publications on create" do
    FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    exercise.result_publications.count.should eq(4)
  end

  it "should destroy result publications on delete" do
    FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    expect {
      exercise.destroy
    }.to change {ResultPublication.count}.by(-4)
  end

  it "should be able to fetch result publication for a given tutorial group" do
    tutorial_groups = FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    result_publication = exercise.result_publication_for(tutorial_groups[1])

    expect(result_publication).to be_present
    expect(result_publication.tutorial_group).to eq(tutorial_groups[1])
  end

  it "should be able to determine result publication status for a given tutorial group" do
    tutorial_groups = FactoryGirl.create_list(:tutorial_group, 4, term: term)
    exercise = FactoryGirl.create(:exercise, term: term)

    expect(exercise.result_published_for? tutorial_groups[1]).to eq(false)
  end
end