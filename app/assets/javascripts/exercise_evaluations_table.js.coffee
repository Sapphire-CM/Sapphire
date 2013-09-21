# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'change', '.exercise-evaluations-table-form input', (e) ->
  $this = $(this)
  $this.closest('form').submit()

$(document).on 'click', '.exercise-evaluations-table-create-submission', (e) ->
  $this = $(this)

  e.preventDefault()
  e.stopPropagation()

  unless $this.hasClass("disabled")
    sg_id = $this.data("student-group-id")
    data = {"student_group_id": sg_id}
    $.post($this.data("url"), data)

$ ->
  $('#exercise_evaluations_table_toolbar').evaluations_table_toolbar()
  $table_container = $('#exercise_evaluations_table_container')

  $table_container.evaluations_table
    toolbar: '#exercise_evaluations_table_toolbar'
    endpoint: $table_container.data("url")
    transposed: $table_container.data("transposed")

