//= require moment
//= require moment/ja.js
//= require jquery3
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require tempusdominus-bootstrap-4.js
//= require_tree .

var data = {'data-date-format': 'YYYY-MM-DD hh:mm:ss' };
$(function(){
  $('.datepicker').attr(data);
  $('.datepicker').datetimepicker();
});
