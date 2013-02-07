require "spec_helper"

describe RatingGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/rating_groups").should route_to("rating_groups#index")
    end

    it "routes to #new" do
      get("/rating_groups/new").should route_to("rating_groups#new")
    end

    it "routes to #show" do
      get("/rating_groups/1").should route_to("rating_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/rating_groups/1/edit").should route_to("rating_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/rating_groups").should route_to("rating_groups#create")
    end

    it "routes to #update" do
      put("/rating_groups/1").should route_to("rating_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/rating_groups/1").should route_to("rating_groups#destroy", :id => "1")
    end

  end
end
