require 'spec_helper'

describe "evaluations/index" do
  before(:each) do
    assign(:evaluations, [
      stub_model(Evaluation),
      stub_model(Evaluation)
    ])
  end

  it "renders a list of evaluations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
