#
#  student_groups.js.coffee
#  Sapphire
#
#  Created by Matthias Link on 2015-02-23.
#  Copyright 2015 Matthias Link. All rights reserved.
#

class Timer
  constructor: (@timeout_interval, @callback) ->
    @timeout = undefined

  start: ->
    @reset()

  reset: ->
    if @timeout
      clearTimeout(@timeout)

    self = @
    @timeout = setTimeout ->

      self._clear_timeout()
      self._perform_callback()
    , @timeout_interval

  clear: ->
    if @timeout
      clearTimeout(@timeout)

  _perform_callback: ->
    @callback()

  _clear_timeout:()->
    @timeout = undefined

$ ->
  $form = $(".student-group-editor")
  if $form.length > 0
    $form.find(".student-group-list-container").disableSelection().sortable({
      connectWith: ".student-list-container"
      dropOnEmpty: true
    });

    $form.find(".student-list-container").disableSelection().sortable({
      connectWith: ".student-group-list-container"
      cancel: ".placeholder"
      dropOnEmpty: true
    });

    $search_form = $form.find(".search-form")
    $search_input = $search_form.find("input[type=search]")

    timer = new Timer 300, ->
      if $search_input.val().length > 3
        $search_form.submit()

    $search_input.on "keydown", (e)=>
      if e.which == 13
        $search_form.submit()
        timer.clear()
      else
        timer.reset()
