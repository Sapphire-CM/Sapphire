$.widget "sapphire.evaluations_table",
  options:
    transposed: false
    endpoint: undefined
    view: undefined
    toolbar: undefined

  _create: ->
    @endpoint = @options.endpoint
    @transpose_table = !!@options.transposed
    @tutorial_group = @options.tutorial_group
    @toolbar_selector = @options.toolbar
    @reload()

  transpose: ->
    @transpose_table = !@transpose_table
    @reload()

  reload:  ->
    if @endpoint
      @load_count ||= 0
      @load_count++
      @element.html("loading table - please be patient - #{@load_count}")
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
        @element.html(data.payload)
        @_update_tutorial_group(data.tutorial_group_id)
        @element.find("*[data-cycle]").cycle()
        @_trigger("reloaded")
    else
      alert("no endpoint set!")

  tutorial_group_selected: (tutorial_group_id)->
    if @tutorial_group != tutorial_group_id
      @tutorial_group = tutorial_group_id
      @reload()

  _update_tutorial_group: (id)->
    if @toolbar_selector
      $(@toolbar_selector).evaluations_table_toolbar("update_tutorial_group", id)

  _endpoint_options: ->
    transpose: @transpose_table
    tutorial_group_id: @tutorial_group