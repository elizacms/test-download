function initDialogs(){
  console.log( 'initDialogs' );
  
  $( '.dialog button' ).click(function( event ){
    event.preventDefault();
    submitDialog( $( this ).parent( 'form' ));
  });
};

function submitDialog( form ){
  $.ajax({
    type: 'POST',
    url: '/dialogue_api/response?' + form.serialize()
  })
  .done( function( data ){
    getDialogs( form );
  });
};

function getDialogs( form ){
  var intent_id = form.children( 'input[name="intent_id"]' ).val();
  var data = { intent_id: intent_id };
  
  $.ajax({
    type: 'GET',
    url: '/dialogue_api/all_scenarios',
    data:data
  })
  .done( function( data ){
    renderDialogs( data );
  });
};

function renderDialogs( data ){
  console.log( data );
};