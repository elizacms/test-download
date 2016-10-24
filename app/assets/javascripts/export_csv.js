function initCSVButton(){
  $( '.dialog button.export-csv' ).click(function( event ){
    event.preventDefault();
    getCSV();
  });
};

function getCSV(){
  var intent_id = $( 'form' ).children( 'input[name="intent-id"]' ).val();
  
  window.location.assign( '/dialogue_api/csv?intent_id=' + intent_id );
};
