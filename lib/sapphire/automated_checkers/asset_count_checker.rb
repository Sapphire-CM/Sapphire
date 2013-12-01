module Sapphire
  module AutomatedCheckers
    class AssetCountChecker < Base
      checks_submissions!

      check :two_assets_or_more_present do
        if subject.submission_assets.count >= 2
          success!
        else
          failed!
        end
      end
    end
  end
end