$ ->
  $('.single-evaluation-form input').change ->
    $(this).closest("form").submit()