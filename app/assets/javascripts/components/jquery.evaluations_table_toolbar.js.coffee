$.widget "sapphire.evaluations_table_toolbar",
  options:
    table_selector: '#exercise_evaluations_table_container'
    view_cycles: []
  _create: ->
    @table_selector = @options.table_selector
    @_bind_handler ".transpose-button", "_transpose_clicked"
    @_bind_handler ".reload-button", "_reload_clicked"
    @_bind_handler ".tutorial_groups_dropdown a", "_tutorial_group_selected"
    @_bind_handler ".orders_dropdown a", "_order_selected"

  update_tutorial_group:(id)->
    @element.find(".tutorial_groups_dropdown a span").remove()
    @element.find(".tutorial_groups_dropdown a[data-tutorial-group-id=#{id}]").prepend("<span style='display:block; float:right'>✔</span>");

  update_order: (order)->
    @element.find(".orders_dropdown a span").remove()
    @element.find(".orders_dropdown a[data-order=#{order}]").prepend("<span style='display:block; float:right'>✔</span>");

  _transpose_clicked: (e) ->
    @_update_table("transpose")
    @_handle_click(e)

  _reload_clicked: (e) ->
    @_update_table("reload")
    @_handle_click(e)

  _tutorial_group_selected: (e)->
    $link = $(e.target)
    @_update_table("tutorial_group_selected", $link.data("tutorial-group-id"))
    @_handle_click(e)

  _order_selected: (e)->
    $link = $(e.target)
    @_update_table("order_selected", $link.data("order"))
    @_handle_click(e)

  _bind_handler: (sel, handler_id) ->
    @_on @element.find(sel),
      click: handler_id

  _update_table: (method, options = undefined)->
    $(@table_selector).evaluations_table(method, options)

  _handle_click: (e)->
    e.preventDefault()
