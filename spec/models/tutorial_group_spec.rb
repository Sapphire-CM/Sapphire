require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TutorialGroup do
  it { should have_many :term_registrations }

  let(:course) { create(:course) }
  let(:term) { create(:term, course: course)}

  it "should ensure result publications on create" do
    FactoryGirl.create_list(:exercise, 4, term: term)
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    tutorial_group.result_publications.count.should eq(4)
  end

  it "should destroy result publications on delete" do
    FactoryGirl.create_list(:exercise, 4, term: term)
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term)

    expect {
      tutorial_group.destroy
    }.to change {ResultPublication.count}.by(-4)
  end
end
