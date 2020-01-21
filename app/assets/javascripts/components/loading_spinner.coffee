@LoadingSpinner =
  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:load', =>
      @remove_spinner()

  spinner: null
  add_spinner: ->
    $('body').addClass('progress-cursor')
  remove_spinner: ->
    clearTimeout(@spinner)
    $('body').removeClass('progress-cursor')

$(document).on 'page:before-change', ->
  LoadingSpinner.spin()
