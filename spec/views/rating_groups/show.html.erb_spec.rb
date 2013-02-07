require 'spec_helper'

describe "rating_groups/show" do
  before(:each) do
    @rating_group = assign(:rating_group, stub_model(RatingGroup))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
