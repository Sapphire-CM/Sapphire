# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  initNewModelRevealModal('#new_rating_group_modal')


initNewModelRevealModal = (id) ->
  # move the reveal modal to the bottom of the page
  # out of the grid-system
  $reveal_modal = $(id)
  $reveal_modal.remove()
  $('body').append $reveal_modal


  $(id).on 'opened', ->
    $('#rating_group_form').show()
    $('#rating_group_form_error').hide()
    $('#new_rating_group_modal_status').hide()


  $(document).on 'ajax:success', '#rating_group_form, #rating_group_form_error', (xhr, data, status) ->
    $('#new_rating_group_modal_status').text 'Rating Group was successfully created.'

    $('#rating_group_form').hide()
    $('#rating_group_form_error').hide()
    $('#new_rating_group_modal_status').show()

    $('#rating_group_index_entries .index_entry_none').hide()
    $('#rating_group_index_entries').append data

    setTimeout(->
      $('#new_rating_group_modal').foundation('reveal', 'close');
    , 1250)

  $(document).on 'ajax:error', '#rating_group_form, #rating_group_form_error', (e, xhr, status, error) ->
    $('#rating_group_form').hide()
    new_form = $(xhr.responseText).attr('id', 'rating_group_form_error')
    $('#rating_group_form_error').replaceWith(new_form).show()
    initRatingGroupForm()



  $(document).on 'ajax:success', '.index_entry_remove', (e, data, xhr, status) ->
    $(this).parents('.index_entry').animate {height: '0'}, 400, 'swing', ->
      $(this).remove()
      $('#rating_group_index_entries .index_entry_none').show() if $('.index_entry').length == 0


  $(document).on 'ajax:error', '.index_entry_remove', (e, data, xhr, status) ->
    console.log "ERROR: index entry remove:", arguments

