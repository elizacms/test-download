function createJSON(){
  var data = $("#fields").jsGrid("option", "data");

  var top = { id:     intent.name ,
              fields: data       };

  return JSON.stringify( top, null, 2 );
}
