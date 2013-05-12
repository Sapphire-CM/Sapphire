# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  initNewModelRevealModal('#rating_group_index_entries', '#new_rating_group_modal')


initNewModelRevealModal = (id_index, id_modal) ->
  # move the reveal modal to the bottom of the page
  # out of the grid-system
  $reveal_modal = $(id_modal)
  $reveal_modal.remove()
  $('body').append $reveal_modal



  $(document).on 'click', '.index_entry_edit', ->
    $(id_modal + ' .form_new').hide()
    $(id_modal + ' .form_edit').show()
    # $(id_modal).foundation('reveal', 'open');

  $(document).on 'click', '.index_entry_new', ->
    $(id_modal + ' .form_new').show()
    $(id_modal + ' .form_edit').hide()

  $(id_modal).on 'opened', ->
    $(id_modal + ' .form_error').hide()
    $(id_modal + ' .status').hide()



  $(document).on 'ajax:success', id_modal + ' form', (xhr, data, status) ->
    $(id_modal + ' .form_new').hide()
    $(id_modal + ' .form_edit').hide()
    $(id_modal + ' .form_error').hide()

    $(id_modal + ' .status').text 'Rating Group was successfully created.'
    $(id_modal + ' .status').show()

    $(id_index + ' .index_entry_none').hide()
    $(id_index).append data

    setTimeout(->
      $(id_modal).foundation('reveal', 'close');
    , 1250)

  $(document).on 'ajax:error', id_modal + ' form', (e, xhr, status, error) ->
    $(id_modal + ' .form_new').hide()
    $(id_modal + ' .form_edit').hide()

    new_form = $(xhr.responseText).removeClass('form_new form_edit').addClass('form_error')
    $(id_modal + ' .form_error').replaceWith(new_form).show()

    initRatingGroupForm()



  $(document).on 'ajax:success', '.index_entry_remove', (e, data, xhr, status) ->
    $(this).parents('.index_entry').animate {height: '0'}, 400, 'swing', ->
      $(this).remove()
      $(id_index + ' .index_entry_none').show() if $('.index_entry').length == 0

  $(document).on 'ajax:error', '.index_entry_remove', (e, data, xhr, status) ->
    console.log "ERROR: index entry remove:", arguments
