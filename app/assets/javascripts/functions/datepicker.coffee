@update_date_pickers = ->
  $('.date_picker input').fdatepicker()
  $('.date_picker label, .date_picker a.button').click ->
    $(this).closest('div.date_picker').find('input').fdatepicker('show');


  $('.datetime_picker input').fdatetimepicker()
  $('.datetime_picker label, .datetime_picker a.button').click (e)->
    $(this).closest('div.datetime_picker').find('input').fdatetimepicker('show');
    e.preventDefault();
    e.stopPropagation();

