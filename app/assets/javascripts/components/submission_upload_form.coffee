class SubmissionUploadFormController
  constructor: (@element) ->
    @_setup()

  _setup: ->
    @input_sel = "#submission_upload_add_to_path"
    @path_sel = ".submission_upload_path"
    @file_sel = ".submission_upload_file"

    @_setupPathInput()
    @_setupDropzone()

    @_updatePathVisibility(false)

  _setupPathInput: ->
    $path = $(@path_sel).find("input")
    @path_input_name = $path.attr("name")
    $path.attr("name", "")

    @element.on "change", @input_sel, =>
      @_updatePathVisibility()

  _setupDropzone: ->
    that = @
    @dropzone = new Dropzone(@element[0], {
      parallelUploads: 5,
      paramName: @element.find(@file_sel).find("input").attr("name")
      init: ->
        @on 'addedfile', (file) ->
          console.log("added", file)

        @on 'sending', (file, xhr, formData) ->
          sapphire_path = $(that.path_sel).find("input").val()

          path = if file.fullPath and file.fullPath != ""
            that._joinPath(sapphire_path, file.fullPath.replace(file.name, ""))
          else
            sapphire_path

          formData.append(that.path_input_name, path)

        @on 'success', (file, json) ->
          console.log("done", file)
      })

  _updatePathVisibility: (animated = true) ->
    $input = @element.find(@input_sel)
    $path = @element.find(@path_sel)

    if $path.is(":animated")
      $path.stop()

    if $path.is(":hidden") && !$input.is(":checked")
      if animated then $path.slideDown() else $path.show()
    else if !$path.is(":hidden") && $input.is(":checked")
      if animated then $path.slideUp() else $path.hide()

  _joinPath: (args...)->
    components = []
    for arg in args
      if arg
        components.push arg.replace(/^\/+|\/+$/, "")

    components.join("/")

$(document).on "page:change", ->
  $form = $("form.submission-upload")

  if $form.length > 0
    controller = new SubmissionUploadFormController($form)
