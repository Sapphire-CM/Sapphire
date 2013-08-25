# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


@disable_student_group_forms = (student_group_id) ->
  $(".exercise-evaluations-table .exercise-evaluations-#{student_group_id} input").prop("disabled", true)

@enable_student_group_forms = (student_group_id) ->
  $(".exercise-evaluations-table .exercise-evaluations-#{student_group_id} input").prop("disabled", false)


$(document).on 'change', '.exercise-evaluations-table-form input', (e) ->
  $this = $(this)
  $this.closest('form').submit()



