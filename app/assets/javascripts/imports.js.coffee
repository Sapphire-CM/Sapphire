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

$ ->
  $(document).on 'change', 'select.import_mapping', ->
    key = $(this).val()
    value = $(this).data('index')
    console.log "#{key} -> #{value}"
    $("input[name='import[import_mapping_attributes][#{key}]']").val(value)

  schedule_poll = ->
    $results_table = $('#results_table')

    if $results_table.length > 0 && $results_table.data("poll")
      setTimeout(->
        $.getScript($results_table.data("poll-url"))
        schedule_poll()
      , 1000)

  if $('#results_table').length > 0
    schedule_poll()
