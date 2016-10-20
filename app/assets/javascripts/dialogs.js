function initDialogs(){
  getDialogs();

  $( '.dialog button' ).click(function( event ){
    event.preventDefault();
    submitDialog( $( this ).parent( 'form' ));
  });
};

function submitDialog( form ){
  var data = { unresolved:[], missing:[], present:[] }

  form.find( 'tr:gt(0)' ).map( function( index, tr ){
    var field = $( tr ).find( 'select[name="field"]' ).val();
    var condition = $( tr ).find( 'select[name="condition"]' ).val();
    var value = $( tr ).find( 'select[name="value"]' ).val();

    data[ condition ].push( field );
  });

  data[ 'intent_id'      ] =   form.find( 'input[name="intent_id"]'       ).val()  ;
  data[ 'response'       ] = [ form.find( 'input[name="response"]'        ).val() ];
  data[ 'awaiting_field' ] =   form.find( 'select[name="awaiting_field"]' ).val()  ;

  if ( $('.aneeda-says').val() == '' ){
    $('.aneeda-says-error').html('This field cannot be blank.');

    setTimeout(function() {
      $('.aneeda-says-error').html('');
    }, 3000);

    return false;
  }

  $.ajax({
    type: 'POST',
    url: '/dialogue_api/response?',
    dataType:'json',
    data:data
  })
  .done( function( data ){
    form.find( 'input.aneeda-says' ).val( '' );
    getDialogs();
  });
};

function deleteDialog( id ){
  $.ajax({
    type: 'DELETE',
    url: '/dialogue_api/response?response_id=' + id
  })
  .done( function( data ){
    $('.response-message').html(data);

    getDialogs();

    setTimeout(function() {
      $('.response-message').html("");
    }, 3000);
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
    // console.log( data );
    renderDialogs( data );
  });
};

function renderDialogs( data ){
  var rows = data.map( function( d ){
    return rowsForSingle( d );
  });

  var flat = [].concat.apply( [], rows );

  $( 'table.dialogs' ).find("tr:gt(0)").remove();
  $( 'table.dialogs' ).append( flat );

  initDeleteListeners();
};

function initDeleteListeners(){
  $( 'table.dialogs .icon-cancel-circled' )
      .click( function( event ){
        if ( confirm("Are you sure you'd like to delete this dialog?") ){
          event.preventDefault();
          deleteDialog( event.target.rel );
        }
  });
};

function rowsForSingle( d ){
  return d.responses.map( function( r ){
    condition = 'error';

    if( d[ 'missing' ] != null )
      condition = 'missing'
    else if( d[ 'present' ] != null )
      condition = 'present'
    else if( d[ 'unresolved' ] != null )
      condition = 'unresolved'

    var tds = [ td( r, 'id' ),
                td( r, 'response' ),
                td( d,  '', d[ condition ][ 0 ] + ' is ' + condition ),
                td( r, 'awaiting_field' ),
                deleteTD( r )];

    var tr = $( '<tr></tr>' ).append( tds );

    return tr;
  });
};

function td( object, field, extraText ){
  var text = '';

  if( object[ field ] != undefined )
    text = object[ field ];

  if( extraText != undefined )
    text += extraText;

  var td = $( '<td></td>' ).attr( 'class', field )
                           .text(  text          );

  return td;
};

function deleteTD( r ){
  var link = $( '<a></a>' ).attr( 'class', 'icon-cancel-circled' )
                           .attr( 'rel',    r.id )
                           .attr( 'href' , '#' );
  return $( '<td></td>' ).html( link );
}
