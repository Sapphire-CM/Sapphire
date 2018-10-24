module FeatureMatchers

  def highlight_side_nav_link(*args)
    success = false
    within ".side-nav li.active" do
      success = have_link(*args)
    end
    success
  end

end


RSpec.configure do |config|
  config.include FeatureMatchers, type: :feature
end
