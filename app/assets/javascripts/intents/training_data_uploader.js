$(document).on('turbolinks:load', function(){
  $('input[type=file]').change(function(e){
    $('.infoText').html($(this)[0].files[0].name).css('color', 'inherit');
  });

  $('.uploadBtn').click(function(e){
    e.preventDefault();

    if ( $('#files').val() === '' ){
      $('.infoText').html('You must attach a file.').css('color', 'red');
      setTimeout(function(){
        $('.infoText').html('').css('color', 'inherit');
      }, 2500);

      return;
    }

    var fileName = $('.infoText').text();
    $('.infoText').html('Saved ' + fileName + '!').css('color', 'green');
    $( '.trainingDataUpload' ).submit();
  });
});
