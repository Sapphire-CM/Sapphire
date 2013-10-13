$.widget "sapphire.evaluations_table",
  options:
    transposed: false
    endpoint: undefined
    view: undefined
    toolbar: undefined
    min_height: 200

  _create: ->
    @endpoint = @options.endpoint
    @transpose_table = !!@options.transposed
    @tutorial_group = undefined
    @order = undefined
    @min_height = @options.min_height
    @toolbar_selector = @options.toolbar
    @pinned_header_table = undefined
    @element.css("position", "relative")
    @reload()
    @_setup_resizing_listener()
    @_fit_table_into_window()

  transpose: ->
    @transpose_table = !@transpose_table
    @reload()

  reload:  ->
    if @endpoint
      @element.html("Loading table - please be patient")
      r = $.ajax
        url: @endpoint
        async: true
        data: @_endpoint_options()
        cache: false
      r.fail (XMLHttpRequest, textStatus, errorThrown) =>
        @element.html("Couldn't load table")
        if console
          console.log "fail", XMLHttpRequest, textStatus, errorThrown

      r.done (data) =>
        @recieved_data = data
        @table_backup = $(data.payload)
        @_reload_table()
        @_trigger("reloaded")

    else
      alert("no endpoint set!")

  tutorial_group_selected: (tutorial_group_id)->
    if @tutorial_group != tutorial_group_id
      @tutorial_group = tutorial_group_id
      @reload()

  order_selected: (order)->
    if @order != order
      @order = order
      @reload()

  _reload_table: ->
    data = @recieved_data
    @element.html("").append(@table_backup)
    @_update_tutorial_group(data.tutorial_group_id)
    @_update_order(data.order)
    @_fit_table_into_window()
    @_pin_headers()
    @element.find("*[data-cycle]").cycle()

  _update_tutorial_group: (id)->
    if @toolbar_selector
      $(@toolbar_selector).evaluations_table_toolbar("update_tutorial_group", id)

  _update_order: (order)->
    if @toolbar_selector
      $(@toolbar_selector).evaluations_table_toolbar("update_order", order)

  _endpoint_options: ->
    transpose: @transpose_table
    tutorial_group_id: @tutorial_group
    order: @order

  _setup_resizing_listener: ->
    $(window).resize =>
      @_fit_table_into_window()
      if (@_repining_timeout)
        clearTimeout(@_repining_timeout);
      @_repining_timeout = setTimeout =>
        @_repining_timeout = undefined
        if @recieved_data
          @table_backup = @element.find("table.fht-table-init").last().attr("style", "").clone().removeClass("fht-table fht-table-init")
          @table_backup.find(".fht-cell").remove()
          @element.find(".table").fixedHeaderTable("destroy")
          @element.html("").append(@table_backup)
          @_reload_table()
      , 200

  _pin_headers: ->
    @element.find("table").fixedHeaderTable
      height: "#{@element.height()}px"
      fixedColumns: 2

  _fit_table_into_window: ->

    win_height = $(window).height()
    el_off_top = @element.offset().top

    height = win_height - el_off_top
    height = @min_height if height < @min_height

    @element.height(height)
