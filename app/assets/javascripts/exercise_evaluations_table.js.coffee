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

$(window).on 'scroll.fht-thead', ->
  windowScrollTop = $(window).scrollTop()
  header = $('.fht-thead').last()

  if @scrolling && windowScrollTop < header.data('scrolling-end') - 45
    @scrolling = false
    header.removeClass('fixed').css({position:'static', top:0, "z-index":50})
    $('.fht-thead').first().show()
    $('#placeholder').hide().height 0

    return
  if header
    if !@scrolling&&  windowScrollTop >= header.offset().top - 45
      header.data 'scrolling-end', header.offset().top
      header.addClass('fixed').css({
        position:"fixed",
        top: 45,
        "z-index":101,
        "margin-left":0,
        "margin-right":0,
        "padding-left":0,
        "padding-right":0
        })

      @scrolling = true
      $('#placeholder').show().height $('.fht-thead').first().height()
      $('.fht-thead').first().hide()

      return
