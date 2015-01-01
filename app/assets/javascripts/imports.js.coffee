$ ->
  $tables = $("table.mapping_table")
  if $tables.length > 0
    $tables.each ->
      $table = $(this)
      $selects = $table.find("select")
      $selects.change (e) ->
        $changed_select = $(this)
        new_value = $changed_select.val()

        $selects.each ->
          $sel = $(this)
          if $sel.val() == new_value
            $sel.val("")

        $changed_select.val(new_value)
        true

$ ->
  $('#import_import_options_matching_groups_first').change ->
    elem = $('#import_import_options_tutorial_groups_regexp')
    $(elem).prop("disabled", !$(this).is(':checked'))

    elem = $('#import_import_options_student_groups_regexp')
    $(elem).prop("disabled", "disabled") if $(this).is(':checked')

  $('#import_import_options_matching_groups_both').change ->
    elem = $('#import_import_options_tutorial_groups_regexp')
    $(elem).prop("disabled", "disabled") if $(this).is(':checked')

    elem = $('#import_import_options_student_groups_regexp')
    $(elem).prop("disabled", !$(this).is(':checked'))

  $('#import_import_options_matching_groups_first').trigger 'change'
  $('#import_import_options_matching_groups_both').trigger 'change'

$ ->
  $('div.row.sync-height > div.columns > div.panel').syncHeight({ 'updateOnResize': true})