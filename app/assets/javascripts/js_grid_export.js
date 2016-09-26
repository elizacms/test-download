function headerValues(){
  return $( '#fields' ).data( 'JSGrid' )
                       .fields
                       .filter( function( d ){
                         return d.name != '';
                       })
                       .map( function( d ){
                         return d.name
                       })
}

function dataObjects(){
  return $( '#fields' ).data( 'JSGrid' ).data
}

function createJSONForSingle( object ){
  var hash = {};
  
  headerValues().map( function( key ){
    hash[ key ] = object[ key ]
  });

  return hash;
}

function createJSON(){
  objects = dataObjects().map( function( o ){
    return createJSONForSingle( o )
  });

  var top = { id:     intent.name ,
              fields: objects     };

  return JSON.stringify( top, null, 2 );
}
