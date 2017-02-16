$(document).on('turbolinks:load', function() {
  if ( $('input[id=intent_requires_authorization]').attr('checked') == 'checked' ){
    $('#authList').collapse('show');
  }
  else {
    $('#authList').collapse('hide');
  }

  $('input[id=intent_requires_authorization]').click(
    function(){
      $('#authList').collapse('toggle');
    }
  );
});
