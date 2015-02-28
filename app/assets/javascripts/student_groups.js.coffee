#
#  student_groups.js.coffee
#  Sapphire
#
#  Created by Matthias Link on 2015-02-23.
#  Copyright 2015 Matthias Link. All rights reserved.
#

class Timer
  constructor: (@timeout_interval, @callback) ->
    @timeout = undefined

  start: ->
    @reset()

  reset: ->
    if @timeout
      clearTimeout(@timeout)

    self = @
    @timeout = setTimeout ->

      self._clear_timeout()
      self._perform_callback()
    , @timeout_interval

  clear: ->
    if @timeout
      clearTimeout(@timeout)

  _perform_callback: ->
    @callback()

  _clear_timeout:()->
    @timeout = undefined

get_entry_id = ($entry) ->
  $entry.data("term-registration-id")

update_student_ids = ($form) ->
  $form.find("input[type=hidden].student-id").remove()
  $form.find(".term-registration-entry").each ->
    $entry = $(@)
    id = get_entry_id $entry

    $input = $("<input type='hidden' name='student_group[term_registration_ids][]' class='student-id'>")
    $input.val(id)
    $input.appendTo($form)

deactivate_existing_students = ($list_to_update, $data_source_list)->
  $list_to_update.find(".term-registration-entry.deactivated").each ->
    $(@).removeClass("deactivated")

  $data_source_list.find(".term-registration-entry").each ->
    $entry = $(@)
    id = get_entry_id($entry)

    $list_to_update.find(".term-registration-entry[data-term-registration-id=#{id}]").each ->
      $(@).addClass("deactivated").appendTo($list_to_update)

$ ->
  $editor = $(".student-group-editor")

  if $editor.length > 0
    $student_group_list = $editor.find(".student-group-list-container")
    $students_list = $editor.find(".student-list-container")
    $form = $($student_group_list.parents("form")[0]);

    $form.on "click", ".remove-button a", ->
      $entry = $($(@).parents(".term-registration-entry")[0])
      $entry.remove()
      update_student_ids($form)
      deactivate_existing_students($students_list, $student_group_list)

    update_student_ids($form)

    $student_group_list.disableSelection().sortable({
      connectWith: ".student-list-container"
      cancel: ".term-registration-entry"
      dropOnEmpty: true,
      update: ->
        $student_group_list.find(".remove-button.hidden").each ->
          $(@).removeClass("hidden")
        update_student_ids($form)
        deactivate_existing_students($students_list, $student_group_list)
    });

    $students_list.disableSelection().sortable({
      connectWith: ".student-group-list-container"
      cancel: ".placeholder, .deactivated"
      dropOnEmpty: true
    }).on "change", ->
      deactivate_existing_students($students_list, $student_group_list)
      $students_list.find(".remove-button").each ->
        $(@).addClass("hidden")

    $search_form = $editor.find(".search-form")
    $search_input = $search_form.find("input[type=search]")

    timer = new Timer 300, ->
      if $search_input.val().length > 3
        $search_form.submit()

    $search_input.on "keydown", (e)=>
      if e.which == 13
        $search_form.submit()
        timer.clear()
      else
        timer.reset()
