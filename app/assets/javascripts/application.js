// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery-ui
//= require jquery_ujs
//= require d3
//= require foundation
//= require turbolinks
//= require dropzone
//= require jquery.remotipart
//= require cocoon
//= require vendor
//= require_tree .

$(function(){
  $(document).foundation();
  window.update_date_pickers();

  $reveal_modal = $("#reveal_modal");
  $reveal_modal.remove();

  $('body').append($reveal_modal);

  $('.alert-box').on('click', function(){
    $(this).children('a').trigger('click.fndtn.alerts');
  });
});
