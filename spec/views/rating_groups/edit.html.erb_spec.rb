require 'spec_helper'

describe "rating_groups/edit" do
  before(:each) do
    @rating_group = assign(:rating_group, stub_model(RatingGroup))
  end

  it "renders the edit rating_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => rating_groups_path(@rating_group), :method => "post" do
    end
  end
end
