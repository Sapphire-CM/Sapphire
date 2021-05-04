class SubmissionUploadFormController
  constructor: (@element) ->
    @_setup()

  _setup: ->
    @input_sel = "#submission_upload_add_to_path"
    @path_sel = ".submission_upload_path"
    @path_edit_button_sel = ".path-description"
    @file_sel = ".submission_upload_file"
    @needs_reload = false

    @_setupPathInput()
    @_setupFileInput()
    @_removeSubmitButton()
    @_setupDropzone()
    @_setupModalHandling()

  _setupPathInput: ->
    $path_el = @element.find(@path_sel)
    $path_input = $path_el.find("input")
    @path_input_name = $path_input.attr("name")

    path_description = (path) ->
      p = ("/" + $path_input.val()).replace(/\/+$/, "").replace(/\/{2,}/g, "/")
      p = "/" if p == ""

      "'#{p}'"

    $path_el.append("<div class='row collapse'>
      <div class='small-1 column'>
        <span class='prefix'>/</span>
      </div>
      <div class='small-10 columns input-placeholder'></div>
      <div class='small-1 column ok-button-placeholder'></div>
    </div>")

    $input_placeholder = $path_el.find(".input-placeholder")
    $ok_placeholder = $path_el.find(".ok-button-placeholder")

    $path_description = $("<p>").addClass("path-description").text("Files will be added to folder ")
    $path_edit_button = $("<a>").attr("href", '#').text("Edit")
    $path_text_el = $("<strong>").text(path_description())
    $path_ok_button = $("<a>").text("ok").addClass("postfix button")

    $path_description.append($path_text_el)
    $path_description.append(" ")
    $path_description.append($path_edit_button)

    $input_placeholder.append($path_input)
    $ok_placeholder.append($path_ok_button)

    $path_el.hide()
    $path_el.find("label").hide()

    # remove old path description (only is present, when users hit back button in their broswers)
    $path_el.find(".path-description").remove()

    $path_description.insertBefore($path_el)

    # Fix Dropzone serialization
    # it would overrule our path implementation, due to FormData.append()
    $path_input.attr("data-dz-prevent-serialization", "true")

    $path_input.on "change", ->
      $path_text_el.text(path_description())
    .on "keypress", (e) ->
      if e.which == 13 # return
        e.stopPropagation()
        e.preventDefault()
        $path_ok_button.trigger("click")
    .on "blur", ->
      $path_ok_button.trigger("click")

    $path_edit_button.on "click", (e) ->
      $path_el.show()
      $path_text_el.hide()
      $path_edit_button.hide()
      $path_input.focus()

      e.preventDefault()
      e.stopPropagation()

    $path_ok_button.on "click", (e) ->
      $path_el.hide()
      $path_text_el.show()
      $path_edit_button.show()
      $path_text_el.text(path_description())


  _setupFileInput: ->
    $file_el = @element.find(@file_sel)

    @dropzone_placeholder = $("<div>").addClass("dropzone-placeholder")

    @dropzone_placeholder.text("Drop files here or click to select")
    @dropzone_placeholder.insertBefore($file_el)
    $file_el.hide()

  _removeSubmitButton: ->
    @element.find("input[type=submit]").hide()

  _setupDropzone: ->
    $preview_container = $("<ul>").addClass("preview-container")
    $preview_container.appendTo(@element)
    $preview_container.hide()

    $preview_template = @element.find(".preview-template")

    that = @
    @dropzone = new Dropzone(@dropzone_placeholder[0], {
      url: @element.attr("action")
      parallelUploads: 5,
      paramName: @element.find(@file_sel).find("input").attr("name")
      previewTemplate: $preview_template.html()
      previewsContainer: $preview_container[0]
      init: ->
        @on 'addedfile', (file) ->
          $preview_container.show()

          if file.fullPath and file.fullPath != ""
            $(file.previewElement).find("*[data-dz-name]").text(file.fullPath)

          $(file.previewElement).find(".status").hide()
          $(file.previewElement).find(".status-progress").show()
          that.needs_reload = true
        @on 'sending', (file, xhr, formData) ->
          sapphire_path = $(that.path_sel).find("input").val()

          path = if file.fullPath and file.fullPath != ""
            that._joinPath(sapphire_path, file.fullPath.replace(file.name, ""))
          else
            sapphire_path

          formData.append("authenticity_token", that.element.find("input[name=authenticity_token]").val())
          formData.append("utf8", that.element.find("input[name=utf8]").val())
          formData.append(that.path_input_name, path)

        @on 'removedfile', (file) ->
          if $preview_container.children().length == 0
            $preview_container.hide()

        @on 'success', (file, json) ->
          $preview_element = $(file.previewElement)
          $preview_element.find(".progress").addClass("success")
          $preview_element.find("*[data-dz-remove]").remove()

          $preview_element.find(".status").hide()
          $(file.previewElement).find(".status-success").show()

        @on 'error', (file) ->
          message = if file.xhr.status == 401
            "You are not authorized to perform this action"
          else
            resp = $.parseJSON(file.xhr.response)
            "File #{resp.errors.file}"

          $error_message = $("<p>").addClass("alert").text(message)
          $preview_el = $(file.previewElement)

          $preview_el.find(".status").hide()
          $preview_el.find(".status-error").show()
          $preview_el.find(".progress").addClass("alert")
          $preview_el.find(".error-container").append($error_message)
      })

  _setupModalHandling: ->
    $modal = @element.parents(".reveal-modal")
    if $modal.length > 0
      $modal.on "closed", =>
        if @needs_reload
          @element.trigger("submission-form:changed")

  _joinPath: (args...)->
    components = []
    for arg in args
      if arg
        components.push arg.replace(/^\/+|\/+$/, "")

    components.join("/")

$(document).on "page:change", ->
  $form = $("form.submission-upload")

  if $form.length > 0
    new SubmissionUploadFormController($form)
