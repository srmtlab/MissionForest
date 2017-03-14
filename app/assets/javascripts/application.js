//= require jquery_ujs
//= require moment
//= require bootstrap-datetimepicker
//= require_tree .

var data = {'data-date-format': 'YYYY-MM-DD hh:mm:ss' }
$(function(){
  $('.datepicker').attr(data)
  $('.datepicker').datetimepicker()
})
