module Sapphire
  module AutomatedCheckers
    class Ex4HTMLTagsChecker < Base
      checks_submissions!

      prepare do
        @files = {}
        submission.submission_assets.htmls.map do |submission_asset|
          @files[File.basename(submission_asset.file.to_s)] = Nokogiri::HTML(submission_asset.file.read)
        end

        @check_if_css_exists_in_any_file = proc do |css_selector|
          @files.values.inject(false) do |found, html|
            if html.css(css_selector).any?
              true
            else
              found
            end
          end
        end

        @check_if_css_exists_in_all_files = proc do |css_selector|
          @files.values.inject(true) do |found, html|
            if html.css(css_selector).any?
              found
            else
              false
            end
          end
        end
      end

      %w(h1 h2 p em ol ul section footer table).each do |tag|
        check "#{tag}_tag_missing".to_sym, "No #{tag}-tag used in any of the files" do
          failed! unless @check_if_css_exists_in_any_file.call(tag)
        end
      end

      check :thead_tfoot_tbody_tags_missing, 'No thead/tbody/tfoot-tag used in any of the files' do
        failed! unless @check_if_css_exists_in_any_file.call('thead, tbody, tfoot')
      end

      %w(script iframe canvas hr br).each do |tag|
        check "#{tag}_tag_present".to_sym, "#{tag}-tag used in any of the files" do
          failed! if @check_if_css_exists_in_any_file.call(tag)
        end
      end

      check :inline_styling_used, 'style-tag or style-attribute used' do
        failed! if @check_if_css_exists_in_any_file.call('style, *[style]')
      end

      check :b_i_u_tag_used, 'b/i/u-tag used in any of the files' do
        failed! if @check_if_css_exists_in_any_file.call('b,i,u')
      end

      check :small_strong_tag_used, 'small/strong-tag used in any of the files' do
        failed! if @check_if_css_exists_in_any_file.call('small, strong')
      end

      check :presentation_attributes_used, 'presentation attributes used in any of the files' do
        failed! if @check_if_css_exists_in_any_file.call('*[border]')
      end

      check :stylesheet_linked_correctly, 'stylesheet incorrectly linked' do
        stylesheets = submission.submission_assets.stylesheets

        success = true
        @files.values.each do |file|
          stylesheets.each do |submission_asset|
            if file.css("link[href='#{File.basename(submission_asset.file.to_s)}']").empty?
              success = false
              failed!
              break
            end
          end

          break unless success
        end
      end

      check :charset_not_utf8, 'All HTMLs have charset=utf-8 specified' do
        failed! unless @check_if_css_exists_in_all_files.call('meta[charset=UTF-8], meta[charset=utf-8]')
      end

      check :no_html_entities_used, 'No HTML entities used' do
        allowed_entities = ['&amp;', '&lt;', '&gt;', '&apos;', '&quot;', '&#xA0;']
        submission.submission_assets.htmls.each do |submission_asset|
          contents = submission_asset.file.read

          matches = contents.scan(/\&[^;]+;/)
          if matches.any? && matches.find { |match_data| !allowed_entities.include?(match_data.first) }.present?
            failed!
            puts submission.submitter.fullname
            break
          end
        end
      end
    end
  end
end
