class SortableTable
  constructor: (@element) ->
    @_extract_rows()
    @_extract_data()
    @_setup_sortable_links()

  # =========
  # = Setup =
  # =========
  _extract_rows: ->
    rows = []
    @element.find("tbody tr").each ->
      $row = $(@)

      cells = []
      $row.find("td").each ->
        $cell = $(@)
        cells.push($cell)

      row = {
        element: $row
        cells: cells
      }

      rows.push(row)
    @rows = rows

  _extract_data: ->
    data = []

    for row in @rows
      values = []
      sort = []

      for $cell in row.cells
        sort_by = if $cell.data("sort")
          $cell.data("sort")
        else
          $cell.text()

        if $cell.data("sort-as") == "integer"
          sort_by = parseInt(sort_by)
          if isNaN(sort_by)
            sort_by = -1

        values.push($cell.html())
        sort.push(sort_by)

      row = {
        values: values
        sort: sort
      }

      data.push(row)

    @data = data

  _setup_sortable_links: ->
    that = @
    links = []
    @element.find("thead th").each (i)->
      $th = $(@)
      if $th.data("sort-disabled")
        return

      $th.wrapInner("<a>")

      $inserted_link = $th.find("a")
      $inserted_link.data("sort-index", i)
      $inserted_link.on "click", (e) =>
        that._handle_sort_click($inserted_link)
        e.stopPropagation()
        e.preventDefault()

      $icon = $("<i>").hide()

      $inserted_link.append(" ")
      $inserted_link.append($icon)
      links.push($inserted_link)

    @links = links

  # ==================
  # = Event Handling =
  # ==================

  _handle_sort_click: ($link) ->
    column_idx = $link.data("sort-index")
    @_sort_by_column(column_idx)

  # ===========
  # = Sorting =
  # ===========

  _sort_by_column: (idx) ->
    desc = @current_sort_column == idx && !@current_desc

    @current_desc = desc
    @current_sort_column = idx

    data = @_sort_data_by_column(idx, desc)
    @_update_table_with_data(data)
    @_update_sort_links(idx, desc)

  _sort_data_by_column: (idx, desc) ->
    @data.sort (a,b) ->
      a_val = a.sort[idx]
      b_val = b.sort[idx]

      cmp = if a_val < b_val
        -1
      else if a_val > b_val
        1
      else
        0

      if desc
        cmp *= -1
      cmp

  _update_table_with_data: (data) ->
    for row_data, row_idx in data
      row = @rows[row_idx]

      for value, cell_idx in row_data.values
        row.cells[cell_idx].html(value)

  _update_sort_links: (active_idx, desc) ->
    for $link, idx in @links
      if idx == active_idx

        icon_class = if desc
          "fi-arrow-down"
        else
          "fi-arrow-up"

        $link.find("i").show().attr("class", icon_class)
      else
        $link.find("i").hide()

setup_sortable_tables = ->
  $("table.sortable").each ->
    $table = $(this)
    new SortableTable($table)


$(document).on "page:load ready", ->
  setup_sortable_tables()
