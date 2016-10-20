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

function saveMturkResponse( e ){
  e.preventDefault();

  var data = { mturk_response: $( e.target ).siblings( 'input#intent_mturk_response' ).val()}

  $( '#submit-result' ).html( '' );

  $.ajax({
    type:'put',
    url: '/skills/' + skill._id.$oid + '/intents/' + intent._id.$oid + '/mturk_response',
    data:data
  })
  .done(function() {
    $( '#submit-result' ).html( 'Saved' );
  })
  .fail(function() {
    $( '#submit-result' ).html( 'Error' );
  });
};

function initMturkResponse(){
  $( '#mturk-response-field input[type="submit"]' ).click( function( e ) {
    saveMturkResponse( e );
  });
}
