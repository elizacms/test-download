function initFieldDataTypes(){
    types = $.ajax({
        type: 'GET',
        dataType: 'json',
        url: '/types/field-data-types',
        data: null
    }).done(function(){
        initFields()
    });
}

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
            loadData: function(){
                filter = { intent_id: intent._id.$oid };
                console.log( filter );
                return ajaxCall( 'GET', '/fields', filter);
            },
            insertItem: function(item){
                var data = $.extend( { intent_id: intent._id.$oid }, item );

                return $.ajax({
                    type: 'POST',
                    dataType: 'json',
                    url: '/fields',
                    data: data
                }).fail(function(r){
                    IAM.alert.run('red', r.responseText, 3000);
                });
            },
            updateItem: function(item){
                return ajaxCall( 'PUT', '/fields/'+ item["_id"]["$oid"], item);
            },
            deleteItem: function(item){
                return ajaxCall( 'DELETE', '/fields/' + item["_id"]["$oid"], null);

            }
        },

        rowClick: function(click){
            $('#dialogs').jsGrid('loadData', click.item );
        },

        fields: [
            {
                title: 'id',
                name: 'name',
                type: 'text',
                width: 100,
                validate: 'required',
                editing: false
            },
            {
                name: 'type',
                type: 'select',
                width: 100,
                validate: 'required',
                items: types.responseJSON,
                valueField: 'name',
                textField: 'name'
            },
            {
                name: 'mturk_field',
                type: 'text',
                width: 100,
                validate: 'required'
            },
            { type: 'control' }
        ]
    })
}

function initJSON(){
    $( 'button.json' ).click(function() {
        $( 'code.json' ).text( createJSON() );

        // Highlight the code.
        $('pre code').each(function(i, block) {
            hljs.highlightBlock(block);
        });
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
    var newData = $.extend(true, [], data);

    $.each(newData, function(index, value){
        delete value['name'];
        delete value['_id'];
    });

    var top = {
                id: intent.name,
                fields: newData,
                mturk_response_fields:[ mturkResponseFields() ]
    };

  return JSON.stringify( top, null, 2 );
}

function mturkResponseFields(){
    return $( 'input#intent_mturk_response' ).val();
}
