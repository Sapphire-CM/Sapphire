module FeatureHelpers
  def ensure_logged_out!
    # return if current_account.nil?

    sign_out
  end

  def sign_in(account = FactoryGirl.create(:account))
    ensure_logged_out!

    sign_in_with(account.email, account.password)

    @current_account = account
  end

  def sign_in_with(email, password)
    visit new_account_session_path

    fill_in 'Email', with: email
    fill_in 'Password', with: password

    click_on 'Sign in'
  end

  def sign_out
    visit destroy_account_session_path
    @current_account = nil
  end

  def click_top_bar_link(*args)
    within '.top-bar' do
      click_link(*args)
    end
  end

  def click_side_nav_link(*args)
    within '.side-nav' do
      click_link(*args)
    end
  end

  def click_sub_nav_link(*args)
    within '.sub-nav' do
      click_link(*args)
    end
  end

  def within_modal(&block)
    within '.reveal-modal.open', &block
  end

  def within_main(&block)
    within "div[role=main]", &block
  end

  def within_header(&block)
    within "div[role=header]", &block
  end

  def hidden_inputs
    return unless block_given?
    previous_value = Capybara.ignore_hidden_elements
    Capybara.ignore_hidden_elements = false

    yield

    Capybara.ignore_hidden_elements = previous_value
  end

  def wait_for_ajax
    return unless block_given?
    previous_value = Capybara.default_max_wait_time
    Capybara.default_max_wait_time = 5

    yield

    Capybara.default_max_wait_time = previous_value
  end

  def drop_in_dropzone(files, css_selector)
    js_script = 'fileList = Array(); '
    files.count.times do |index|
      # Generate a fake input selector
      page.execute_script("if ($('#seleniumUpload#{index}').length == 0) { " \
                          "seleniumUpload#{index} = window.$('<input/>')" \
                          ".attr({id: 'seleniumUpload#{index}', type:'file'})" \
                          ".appendTo('body'); }")

      # Attach file to the fake input selector through Capybara
      attach_file("seleniumUpload#{index}", files[index], visible: false)
      # Build up the fake js event
      #
      js_script << "fileList.push(seleniumUpload#{index}.get(0).files[0]); "
    end

    js_script << "e = $.Event('drop'); "
    js_script << "e.dataTransfer = { files : fileList }; "
    js_script << "$('#{css_selector}')[0].dropzone.listeners[0].events.drop(e);"

    # Trigger the fake drop event
    page.execute_script(js_script)
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
