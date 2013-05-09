# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  # move the reveal modal to the bottom of the page
  # out of the grid-system
  new_rating_group_modal = $('#new_rating_group_modal')
  new_rating_group_modal.remove
  $('body').append new_rating_group_modal

  $('#rating_group_form').bind 'ajax:success', (xhr, data, status) ->
    $('#rating_group_form').text "Done."
    $('#rating_group_index_none').remove
    $('#rating_group_index').append data

  $('#rating_group_form').bind 'ajax:error', (xhr, status, error) ->
    $('#rating_group_form').text "Failed. Please try again later." + status + " " + error