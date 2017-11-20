require 'rails_helper'

RSpec.describe PointsHelper, type: :helper do
  describe '#points' do
    it "returns singular string if 1 is passed" do
      expect(helper.points(1)).to eq("1 point")
    end

    it "returns plural string if 0 is passed" do
      expect(helper.points(0)).to eq("0 points")
    end

    it "returns plural string if 2 is passed" do
      expect(helper.points(2)).to eq("2 points")
    end

    it "returns plural string if 42 is passed" do
      expect(helper.points(42)).to eq("42 points")
    end

    it "returns valid string if -1 is passed" do
      expect(helper.points(-1)).to eq("-1 point")
    end

    it "returns valid string if -2 is passed" do
      expect(helper.points(-2)).to eq("-2 points")
    end
  end
end
