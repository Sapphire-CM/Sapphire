module Sapphire
  def self.running_on_windows?
    RUBY_PLATFORM.include?("mingw")
  end
end