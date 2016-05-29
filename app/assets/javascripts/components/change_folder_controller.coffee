class ChangeFolderController
  constructor: (@element) ->
    @_setupLoadingURL()
    @_setupDeboundedLoading()
    @_setupUI()

  _setupLoadingURL: ->
    @loading_url = @element.attr("data-validation-path")

  _setupDeboundedLoading: ->
    @_validateFolderName = $.debounce 250, =>
      @_checkFolderName()

  _setupUI: ->
    @input = @element.find("input#submission_folder_name")
    @input.keyup =>
      @_updateUI()
      @_validateFolderName()


    @submit_button = @element.find("input[type=submit]")

    @validation_progress = @element.find("span.validation-progress")
    @validation_passed = @element.find("span.validation-passed")
    @validation_failed = @element.find("span.validation-failed")

    @_hideStatusSpans()
    @_updateUI()

  _checkFolderName:->
    value = @input.val()

    if value && @last_value != value
      @_hideStatusSpans()
      @validation_progress.show()
      params = @element.serialize()

      $.ajax
        url: @loading_url
        data: params
        success: (data) =>
          @_hideStatusSpans()

          if data.available
            @validation_passed.show()
          else
            @validation_failed.show()

        error: =>
          @_hideStatusSpans()
          @validation_failed.show()

  _updateUI: () ->
    if @input.val()
      @submit_button.removeClass("disabled")
    else
      @_hideStatusSpans()
      @submit_button.addClass("disabled")

  _hideStatusSpans: ->
    $element.hide() for $element in [@validation_progress, @validation_passed, @validation_failed]

$(document).on "page:change", ->
  $form = $(".change-folder-form")

  if $form.length > 0
    new ChangeFolderController($form)
