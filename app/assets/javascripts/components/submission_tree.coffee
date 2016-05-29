class SubmissionTreeController
  constructor: (@element) ->
    @update_url = @element.data("update-url")

  reload: ->
    $.getJSON @update_url, (data) =>
      @element.html(data.directory)

$(document).on "page:change", ->
  if ($tree = $(".submission-tree")).length > 0
    controller = new SubmissionTreeController($tree)

    if ($form = $("form.submission-upload")).length > 0
      $form.on "submission-form:changed", ->
        controller.reload()

