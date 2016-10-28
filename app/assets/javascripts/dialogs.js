function initDialogs(){
  getDialogs();

  $( '.dialog button.dialog-btn' ).click(function( event ){
    event.preventDefault();
    submitDialog( $( this ).parent( 'form' ));
  });
};

function submitDialog( form ){
  var data = {}

  data[ 'intent_id'  ] = form.find( 'input[name="intent-id"]'         ).val();
  data[ 'priority'   ] = form.find( 'input[name="priority"]'          ).val();
  data[ 'response'   ] = form.find( 'input[name="response"]'          ).val();
  data[ 'unresolved' ] = form.find( 'select[name="unresolved-field"]' ).val();
  data[ 'missing'    ] = form.find( 'select[name="missing-field"]'    ).val();

  var present = [ form.find( 'select[name="present-field"]' ).val() ,
                  form.find( 'input[name="present-value"]'  ).val() ]
  data[ 'present' ] = present;

  data[ 'awaiting_field' ] = form.find( 'select[name="awaiting-field"]' ).val();

  if ( $('.aneeda-says').val().replace( /\s/g, '' ) == '' ){
    $('.aneeda-says-error').html('This field cannot be blank.');

    setTimeout(function() {
      $('.aneeda-says-error').html('');
    }, 3000);

    return false;
  }

  $.ajax({
    type: 'POST',
    url: '/dialogue_api/response?',
    dataType: 'json',
    data: data
  })
  .done( function( data ){
    clearForm( form );
    getDialogs();
  })
  .fail(function(error){
    IAM.alert.run('red', error.getResponseHeader('Warning'), 5000);
  });
};

function clearForm( form ){
  form.find( 'input.aneeda-says'       ).val( '' );
  form.find( 'input.present-value'     ).val( '' );
  form.find( 'input.priority-input'    ).val( '' );
  form.find( 'select#unresolved-field' ).val( '' );
  form.find( 'select#missing-field'    ).val( '' );
  form.find( 'select#present-field'    ).val( '' );
  form.find( 'select#awaiting-field'   ).val( '' );
}

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
  var intent_id = $( 'form' ).children( 'input[name="intent-id"]' ).val();
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
    conditions = [];

    console.log(d);

    if( d.unresolved != null )
      conditions.push( d.unresolved + ' is unresolved' );
    if( d.missing != null )
      conditions.push( d.missing + ' is missing' );
    if( d.present != null )
      conditions.push( d.present[ 0 ] + ' is present: "' + d.present[ 1 ] + '"' );

    var tds = [ td( r, 'id' ),
                td( d, 'priority'),
                td( r, 'response' ),
                td( d, null, conditions.join( '<br>' )),
                td( r, 'awaiting_field' ),
                deleteTD( r )];

    var tr = $( '<tr></tr>' ).addClass( 'dialog-data' ).append( tds );

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
                           .html(  text          );

  return td;
};

function deleteTD( r ){
  var link = $( '<a></a>' ).attr( 'class', 'icon-cancel-circled' )
                           .attr( 'rel',   r.id )
                           .attr( 'href' , '#' );
  return $( '<td></td>' ).html( link );
}
