
var types = [
    { name: "Boolean"  },
    { name: "Time"     },
    { name: "DateTime" }
];

function initFields(){
    $("#fields").jsGrid({
        width: "100%",
        height: "300px",

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
                return ajaxCall( 'POST', '/fields', item);
            },
            updateItem: function(item){
                return ajaxCall( 'PUT', '/fields/'+ item.id, item);  
            },
            deleteItem:function(item){
                return ajaxCall( 'DELETE', '/fields/' + item.id, null);
            }
        },

        rowClick: function(click){
            $("#dialogs").jsGrid("loadData", click.item );
        },

        fields: [
            { name: "id",   type: "text",   validate:"required", visible:false, },
            { name: "name", type: "text",   width: 150,   validate: "required" },
            { name: "type", type: "select", items: types, valueField: "name", textField: "name" },
            { type: "control" }
        ]
})}

function initDialogs(){
    $("#dialogs").jsGrid({
        width: "100%",
        height: "300px",

        inserting: true,
        editing:   true,
        sorting:   false,
        paging:    false,
        autoload:  false,

        controller: {
            loadData: function(field) {
                currentField = field;
                showAddButton();
                var path = '/fields/' + field.id + '/dialogs';
                return ajaxCall( 'GET', path, null );
            },
            insertItem: function(item) {
                var path = '/fields/' + currentField.id + '/dialogs';
                return ajaxCall( 'POST', path, item);
            },
            updateItem: function(item) {
                var path = '/fields/' + item.field_id + '/dialogs/' + item.id;
                return ajaxCall( 'PUT', path, item);  
            },
            deleteItem:function(item) {
                var path = '/fields/' + item.field_id + '/dialogs/' + item.id;
                return ajaxCall( 'DELETE', path, null);
            }
        },

        fields: [
            { name: "id",       type: "text", validate: "required", visible:false, },
            { name: "field_id", type: "text", validate: "required", visible:false },
            { name: "response", type: "text", width:150,  validate: "required" },
            { type: "control" }
        ]
})}

function showAddButton(){
    $( '#dialogs .jsgrid-insert-mode-button' ).show();
}


function ajaxCall( type, url, data ){
    return $.ajax({
        type: type,
        dataType: "json",
        url: url,
        data: data
    });
}
