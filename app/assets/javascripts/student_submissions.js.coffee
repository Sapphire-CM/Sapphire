$ ->
  $(document).on 'click', '.archive_extract a.check_all', (e) ->
    $(this).closest('.archive_extract').find('input[type="checkbox"]').prop('checked', true);
    e.preventDefault()
    e.stopPropagation()

  $(document).on 'click', '.archive_extract a.uncheck_all', (e) ->
    $(this).closest('.archive_extract').find('input[type="checkbox"]').prop('checked', false);
    e.preventDefault()
    e.stopPropagation()
