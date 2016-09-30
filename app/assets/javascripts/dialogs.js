function initDialogs(){
  getDialogs();
  
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
    getDialogs();
  });
};

function getDialogs(){
  var intent_id = $( 'form' ).children( 'input[name="intent_id"]' ).val();
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
  var rows = data.map( function( d ){
    return rowsForSingle( d );
  });

  var flat = [].concat.apply( [], rows );
  console.log( flat );

  $( 'table.dialogs' ).find("tr:gt(0)").remove();
  $( 'table.dialogs' ).append( flat );
};

function rowsForSingle( d ){
  var del = { 'delete': 'x' };
  
  return d.responses.map( function( r ){
    var tds = [ td( r,  'id' ),
                td( r,  'response' ),
                td( d,  'missing', ' is missing' ),
                td( r,  'awaiting_field' ),
                td( del, 'delete' )];

    var tr = $( '<tr></tr>' ).append( tds );
    
    return tr;
  });
};

function td( object, field, extraText ){
  var text = object[ field ];
  if( extraText != undefined )
    text += extraText;

  var td = $( '<td></td>' ).attr( 'class', field )
                    .text(  text          );

  return td;
};