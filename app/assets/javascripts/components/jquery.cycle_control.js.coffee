$.widget "sapphire.cyclecontrol",
  _create: ->
    @data = @element.data("cycle-control")
    @identifier = @data["cycle_to"]
    @selector = @data['selector']
    @_on @element, click: "_clicked"

  _clicked: (e)->
    $(".#{@selector}").each (i, el) =>
      $(el).cycle("cycle_to", @identifier)
    e.preventDefault()

$ ->
  $("*[data-cycle-control]").cyclecontrol()
