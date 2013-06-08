// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.mouse
//= require jquery.ui.position
//= require jquery.ui.sortable
//= require jquery.turbolinks
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require vendor
//= require_tree .

$(function(){
  $(document).foundation();
  $('.date_picker input').fdatepicker();
  $('.date_picker label, .date_picker a.button').click(function(){
    $(this).closest('div.date_picker').find('input').fdatepicker('show');
  });
  $('.datetime_picker input').fdatetimepicker();
  $('.datetime_picker label, .datetime_picker a.button').click(function(e){
    $(this).closest('div.datetime_picker').find('input').fdatetimepicker('show');
    e.preventDefault();
    e.stopPropagation();
  });
});

$(function(){
  $reveal_modal = $("#reveal_modal");
  $reveal_modal.remove();
  $('body').append($reveal_modal);
});

$(function(){
  $('.alert-box').on('click', function(){
    $(this).children('a').trigger('click.fndtn.alerts');
  });
});
