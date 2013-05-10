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
    $('#new_rating_group_modal_status').text 'Rating Group was successfully created.'

    $('#rating_group_form').hide()
    $('#new_rating_group_modal_status').show()

    $('#rating_group_index_none').remove
    $('#rating_group_index').append data

    setTimeout(closeModal, 1500)

  $('#rating_group_form').bind 'ajax:error', (xhr, status, error) ->
    $('#new_rating_group_modal_status').text "Failed. Please try again later." + status + " " + error

    $('#rating_group_form').hide()
    $('#new_rating_group_modal_status').show()

  $('#new_rating_group_modal').bind 'opened', ->
    $('#rating_group_form').show()
    $('#new_rating_group_modal_status').hide()

closeModal = ->
    $('#new_rating_group_modal').foundation('reveal', 'close');

