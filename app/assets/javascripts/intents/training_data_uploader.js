$(document).on('turbolinks:load', function(){
  $('input[type=file]').change(function(e){
    $('.infoText').html($(this)[0].files[0].name);
  });

  $('.uploadBtn').click(function(){
    var fileName = $('.infoText').text();
    $('.infoText').html('Saved ' + fileName + '!').css('color', 'green');
  });
});
