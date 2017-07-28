function initFieldDataTypes(){
    types = $.ajax({
        type: 'GET',
        dataType: 'json',
        url: '/api/field-data-types',
        data: null
    }).done(function(){
        var filter = { id: intent._id.$oid };
        locked = ajaxCall( 'GET', '/file_lock', filter ).done(function(){
            initFields()
        })
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
                var newData = setUpData();
                newData.push(item);
                var data = JSON.stringify({ intent_id: intent._id.$oid, fields: newData });

                postAllFields(data);
            },
            updateItem: function(item){
                var newData = setUpData();
                var data = JSON.stringify({ intent_id: intent._id.$oid, fields: newData });

                postAllFields(data);
            },
            deleteItem: function(item){
                var newData = setUpData();
                var index = newData.findIndex(d => d.name === item.name);
                newData.splice(index, 1);
                var data = JSON.stringify({ intent_id: intent._id.$oid, fields: newData });

                postAllFields(data);
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
                    return /^[a-zA-Z0-9_]+$/.test(value);
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
        invalidMessage: "Cannot be empty and alphanumeric characters only"
    });
}

function setUpData(){
    var fData = $("#jsGrid").jsGrid("option", "data");
    var newData = $.extend(true, [], fData);

    $.each(newData, function(index, value){
        delete value['id'];
    });

    return newData;
}

function postAllFields(data){
    return $.ajax({
        type: 'POST',
        dataType: 'json',
        url: '/fields',
        contentType: 'application/json',
        data: data
    }).done(function(r){
        initFields();
    }).fail(function(r){
        IAM.alert.run('red', r.responseText, 3000);
    });
}

function getCustomInsertControls(gridId) {
    if ( !locked.responseJSON.file_lock ){
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
}

function ajaxCall( type, url, data ){
    return $.ajax({
        type: type,
        dataType: 'json',
        url: url,
        data: data
    });
}

function mturkResponseFields(){
    return $( 'input#intent_mturk_response' ).val();
}
