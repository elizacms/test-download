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
                return ajaxCall( 'PUT', '/fields/'+ item['id']['$oid'], item);
            },
            deleteItem: function(item){
                return ajaxCall( 'DELETE', '/fields/' + item['id']['$oid'], null);

            }
        },

        rowClick: function(click){
            $('#dialogs').jsGrid('loadData', click.item );
        },

        fields: [
            {
                title: 'id "name"',
                name: 'name',
                type: 'text',
                width: 100,
                editing: false,
                validate: function(value){
                    return /^[a-zA-Z0-9_]*$/.test(value);
                }
            },
            {
                name: 'type',
                type: 'select',
                width: 80,
                validate: 'required',
                items: types.responseJSON,
                valueField: 'name',
                textField: 'name'
            },
            {
                title: 'Training Data',
                name: 'mturk_field',
                type: 'text',
                width: 100
            },
            {
                type: 'control',
                width: 100,
                modeSwitchButton: false,
                insertTemplate: function() { return getCustomInsertControls("#jsGrid") },
            }
        ],
        invalidMessage: "Alphanumeric characters only"
    });
}

function getCustomInsertControls(gridId) {
    var grid = $(gridId).data('JSGrid');
    return $("<input>").addClass('btn sm black pull-left')
                      .attr({ type: 'button', value: 'Save' })
                      .css('width', '30%')
                      .on('click', function () {
                          grid.insertItem().done(function () {
                              grid.option("inserting", false)
                          });
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
        delete value['id'];
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
