# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'change', '.exercise-evaluations-table-form input', (e) ->
  $this = $(this)
  $this.closest('form').submit()


$ ->
  $containers = $('.exercise-evaluations-table-container')

  if $containers.length > 0
    $.get $containers.first().data("url")
