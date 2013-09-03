$.widget "sapphire.cyclecontrol",
  _create: ->
    data = @element.data("cycle-control")
    @cyclers = $(".#{data['selector']}")
    @identifier = data["cycle_to"]
    @_on @element, click: "_clicked"

  _clicked: (e)->
    @cyclers.each (i, el) =>
      $(el).cycle("cycle_to", @identifier)
    e.preventDefault()

$ ->
  $("*[data-cycle-control]").cyclecontrol()
