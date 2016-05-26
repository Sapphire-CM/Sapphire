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
