
var types = [
    { name: 'Boolean'  },
    { name: 'Time'     },
    { name: 'DateTime' },
    { name: 'Text'     }
];

function initFields(){
    $('#jsGrid').jsGrid({
        width: '100%',
        height: '300px',

        inserting: true,
        editing:   true,
        sorting:   false,
        paging:    false,
        autoload:  true,

        controller: {
            loadData: function(filter){
                return ajaxCall( 'GET', '/fields', filter);
            },
            insertItem: function(item){
                var data = $.extend({ intent_id:intent._id.$oid }, item );

                return ajaxCall( 'POST', '/fields', data);
            },
            updateItem: function(item){
                return ajaxCall( 'PUT', '/fields/'+ item.id, item);
            },
            deleteItem: function(item){
                return ajaxCall( 'DELETE', '/fields/' + item.id, null);

            }
        },

        rowClick: function(click){
            $('#dialogs').jsGrid('loadData', click.item );
        },

        fields: [
            { name: 'id',          type: 'text',   width:100, validate:'required', editing:false },
            { name: 'type',        type: 'select', width:100, validate:'required', items: types, valueField: 'name', textField: 'name' },
            { name: 'mturk_field', type: 'text',   width:100, validate:'required' },
            { type: 'control' }
        ]
})}

function initJSON(){
    $( 'button.json' ).click(function() {
        $( 'div.json' ).text( createJSON() );
    });
}

function ajaxCall( type, url, data ){
    return $.ajax({
        type: type,
        dataType: 'json',
        url: url,
        data: data
    });
}

function createJSON(){
  var data = $("#jsGrid").jsGrid("option", "data");

  var top = { id: intent.name,
              fields: data,
              mturk_response_fields: mturkResponseFields() };

  return JSON.stringify( top, null, 2 );
}

function mturkResponseFields(){
    return $( 'input#intent_mturk_response' ).val();
}
