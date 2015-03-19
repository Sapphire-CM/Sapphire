module Sapphire
  module AutomatedCheckers
    class Ex5GraztimesStyleChecker < Base
      content_types 'text/css'
      asset_identifier 'stylesheet/graztimes'

      prepare do
        @css = CssParser::Parser.new
        @css.load_string!(subject.read)
        # TODO: remove me later!
        ActiveRecord::Base.logger = nil
      end

      check :sizes, 'No px used' do
        @css.each_selector do |_selector, declarations, _specivity|
          if declarations =~ /px/
            failed!
            break
          end
        end
      end
    end
  end
end
