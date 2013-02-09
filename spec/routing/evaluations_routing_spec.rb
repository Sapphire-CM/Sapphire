require "spec_helper"

describe EvaluationsController do
  describe "routing" do

    it "routes to #index" do
      get("/evaluations").should route_to("evaluations#index")
    end

    it "routes to #new" do
      get("/evaluations/new").should route_to("evaluations#new")
    end

    it "routes to #show" do
      get("/evaluations/1").should route_to("evaluations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/evaluations/1/edit").should route_to("evaluations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/evaluations").should route_to("evaluations#create")
    end

    it "routes to #update" do
      put("/evaluations/1").should route_to("evaluations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/evaluations/1").should route_to("evaluations#destroy", :id => "1")
    end

  end
end
