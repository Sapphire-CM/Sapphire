//= require jquery
//= require_self

$("#toolbar select").change(function(){
  window.location = $(this).val();
});