format_points = (val) ->
  window.pluralize(val, "point", "points")

update_value_tag = ($input) ->
  $input.parent().next(".value").text format_points $input.val()

$(document).on "ready page:load", ->
  $("input[type|=range]").each (i, element)->
    update_value_tag $ element

  $(document).delegate "input[type|=range]", "change", (e)->
    update_value_tag $ this

  $(document).on "cocoon:after-insert", (e) ->
    $this = $(this)
    window.update_date_pickers($this)

