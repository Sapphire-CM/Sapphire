$.widget "sapphire.cycle",
  cycles: undefined
  cycle_identifiers: undefined
  cycle_values: undefined
  current_cycle: 0

  _create: ->
    @cycles = @element.data("cycle")
    @cycle_identifiers = {}
    @cycle_values = []
    @current_cycle = 0

    @_setup_widget()
    @_update_element()


  cycle_to: (identifier)->
    @current_cycle = @cycle_identifiers[identifier]
    @_update_element()

  _setup_widget: ->
    i = 0
    for identifier, value of @cycles
      @cycle_identifiers[identifier] = i
      @cycle_values.push value
      i += 1

    @_on @element,
      click: "cycle_next"

  cycle_next: ->
    @current_cycle += 1
    if @current_cycle >= @cycle_values.length
      @current_cycle = 0
    @_update_element()

  _update_element: ->
    @element.html(@cycle_values[@current_cycle])


$ ->
  $('*[data-cycle]').each (i,el) ->
    $(el).cycle()