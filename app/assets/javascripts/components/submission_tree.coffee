class SubmissionTreeController
  constructor: (@element) ->
    @_setup()

  _setup: ->
    @_setupDragAndDrop()
    @_setupSelection()

  _setupDragAndDrop: ->

  _setupSelection: ->
    $rows = []
    $last_row = undefined

    deselect_all = ->
      console.log("deselecting all")
      $rows.removeClass("selected")

    select = ($row) ->
      console.log("selecting", $row)
      $row.addClass("selected")
      $last_row = $row

    deselect = ($row) ->
      $row.removeClass("selected")
      $last_row = undefined
    toggle = ($row) ->
      $row.toggleClass("selected")

    $rows = @element.find("tr").click (e)->
      if $(e.target).closest("a").length > 0
        return

      $row = $(@)
      selected_rows = []

      for row in $rows
        $row_el = $(row)
        selected_rows.push($row_el) if $row_el.hasClass("selected")

      if e.shiftKey && $last_row
        last_idx = $last_row.index()
        this_idx = $row.index()
        range = [last_idx, this_idx].sort()

        for i in [range[0]..range[1]]
          select $($rows[i])

      else if $row.hasClass("selected")
        console.log(selected_rows)
        if selected_rows.length > 1
          deselect_all()
          select $row
        else
          deselect $row

      else
        deselect_all()
        select $row


      e.stopPropagation()
      e.preventDefault()
      false

$(document).on "page:change", ->
  if ($tree = $(".submission-tree")).length > 0
    controller = new SubmissionTreeController($tree)
