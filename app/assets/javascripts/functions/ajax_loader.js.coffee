@ajax_load = (id, url, indicator) ->
  $element = $('#' + id)
  $element.append indicator

  $.get url, (data) ->
    $element.replaceWith data
