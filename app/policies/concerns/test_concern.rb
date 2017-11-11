module TestConcern
  extend ActiveSupport::Concern

  included do
    raise "test"
  end
end