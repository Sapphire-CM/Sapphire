# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


preview_selection = ($el) ->
  $table = $el.closest("table")

  $thead = $table.find("thead")
  $row = $el.closest("tr")

  $table = $("<table>").addClass("small-12")
  $table.append($thead.clone())
  $table.append($("<tbody>").append($row.clone()))

  $('#term_staff_account_selection').html($table)

$ ->
  $('#term_registration_role').on "change", ->
    $('#term_registration_tutorial_group_id').parent().slideToggle()

  $(document).on 'click', '#term_staff_search_results a[data-account-id]', (e) ->
    $this = $(@)

    $('#term_registration_account_id').val($this.data("account-id"));

    preview_selection($this)

    do e.preventDefault
    do e.stopPropagation
