# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $reveal_modal = $("#reveal_modal")
  $reveal_modal.remove()
  $('body').append $reveal_modal
