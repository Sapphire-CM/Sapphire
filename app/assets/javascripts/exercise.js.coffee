# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  # move the reveal modal to the bottom of the page
  # out of the grid-system
  new_rating_group_modal = $('#new_rating_group_modal')
  new_rating_group_modal.remove()
  $('body').append new_rating_group_modal


  $('#new_rating_group_modal').on 'opened', ->
    $('#rating_group_form').show()
    $('#rating_group_form_error').hide()
    $('#new_rating_group_modal_status').hide()


  $(document).on 'ajax:success', '#rating_group_form, #rating_group_form_error', (xhr, data, status) ->
    $('#new_rating_group_modal_status').text 'Rating Group was successfully created.'

    $('#rating_group_form').hide()
    $('#rating_group_form_error').hide()
    $('#new_rating_group_modal_status').show()

    $('#rating_group_index_none').remove()
    $('#rating_group_index').append data

    setTimeout(->
      $('#new_rating_group_modal').foundation('reveal', 'close');
    , 1250)

  $(document).on 'ajax:error', '#rating_group_form, #rating_group_form_error', (e, xhr, status, error) ->
    $('#rating_group_form').hide()
    new_form = $(xhr.responseText).attr('id', 'rating_group_form_error')
    $('#rating_group_form_error').replaceWith(new_form).show()
    initRatingGroupForm()



  $(document).on 'ajax:success', '.rating_group_index_remove', (e, data, xhr, status) ->
    $(this).parents('.rating_group_index_entry').animate {height: '0'}, 500, 'swing', ->
      $(this).remove()

  $(document).on 'ajax:error', '.rating_group_index_remove', (e, data, xhr, status) ->
    console.log "ERROR: index entry remove:", arguments

