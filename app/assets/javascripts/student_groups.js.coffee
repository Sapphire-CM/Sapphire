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

update_hint_visibility = ($hint, $student_group_list) ->
  if $student_group_list.find(".term-registration-entry").length > 0
    $hint.hide()
  else
    $hint.show()

$ ->
  $editor = $(".student-group-editor")

  if $editor.length > 0
    $student_group_list = $editor.find(".student-group-list-container")
    $students_list = $editor.find(".student-list-container")
    $form = $student_group_list.closest("form")
    $hint = $student_group_list.find(".hint")

    update_student_ids($form)
    update_hint_visibility($hint, $student_group_list)

    $form.on "click", ".remove-button a", ->
      $entry = $(@).closest(".term-registration-entry")
      $entry.remove()
      update_student_ids($form)
      deactivate_existing_students($students_list, $student_group_list)
      update_hint_visibility($hint, $student_group_list)

    $student_group_list.disableSelection().sortable({
      connectWith: ".student-list-container"
      cancel: ".term-registration-entry,.hint"
      dropOnEmpty: true,
      update: ->
        $student_group_list.find(".remove-button.hidden").each ->
          $(@).removeClass("hidden")

        update_hint_visibility($hint, $student_group_list)
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
      update_hint_visibility($hint, $student_group_list)

    $search_form = $editor.find(".search-form")
    $search_input = $search_form.find("input[type=search]")

    $search_input.on "search change", (e)=>
      unless $search_input.val().match(/^\s*$/)
        $search_form.submit()
