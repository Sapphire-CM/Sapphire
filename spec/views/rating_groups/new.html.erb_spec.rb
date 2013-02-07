require 'spec_helper'

describe "rating_groups/new" do
  before(:each) do
    assign(:rating_group, stub_model(RatingGroup).as_new_record)
  end

  it "renders new rating_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => rating_groups_path, :method => "post" do
    end
  end
end
