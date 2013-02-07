require 'spec_helper'

describe "rating_groups/index" do
  before(:each) do
    assign(:rating_groups, [
      stub_model(RatingGroup),
      stub_model(RatingGroup)
    ])
  end

  it "renders a list of rating_groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
