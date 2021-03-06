var buildTable = function(data) {
  data.forEach(function(d, index){
    $('#singleWordTable').append( '<tr class="single_word_row" data-index="'+index+'">'
                                +   '<td class="table-view">'
                                +     d[0]
                                +   '</td>'
                                +   '<td class="table-view">'
                                +     d[1].split("{{")[1].split("}}")[0].split(":")[1]
                                +   '</td>'
                                +   '<td class="table-view single-word-rule-edit-save-btn">'
                                +     '<a href="#" class="edit-btn hide-visibility btn md grey">Edit</a>'
                                +   '</td>'

                                +   '<td class="input-view displayNone">'
                                +     '<input type="text" class="single-word-rule-input width200" value="'+d[0]+'"/>'
                                +   '</td>'
                                +   '<td class="input-view displayNone">'
                                +     '<select class="intents-options"></select>'
                                +   '</td>'
                                +   '<td class="input-view single-word-rule-edit-save-btn displayNone">'
                                +     '<a href="#" class="save-btn btn md black">Save</a>'
                                +   '</td>'
                                + '</tr>'
                                );
  });
};

var getData = function() {
  $.ajax({
    type: 'GET',
    url: '/api/single_word_rules',
    dataType: "json",
    headers: {
      'Accept': 'application/json'
    }
  })
  .done(function(data){
    buildTable(data);

    getIntents();

    checkLock();

    addAction();

    editAction();

    saveAction();
  })
  .fail(function(err){
    console.log( err );
  });
};

var appendOptions = function(intents) {
  intents.forEach(function(intent){
    $('.intents-options').append('<option value="'+intent+'">'+intent+'</option>');
  });
};

var getIntents = function() {
  $.ajax({
    type: 'GET',
    url: '/api/intents',
    headers: {
      'Accept': 'application/json'
    }
  })
  .done(function(intents) {
    appendOptions(intents);
  })
  .fail(function(err){
    console.log( err );
  });
};

var checkLock = function() {
  $.ajax({
    type: 'GET',
    url:  '/api/single_word_rules/check_lock'
  })
  .done(function(res){
    if (res.is_locked == false){
      $('.edit-btn').removeClass("hide-visibility");
    } else {
      $('.edit-btn').addClass("hide-visibility");
    }
  })
  .fail(function(err){
    console.log( err );
  })
};

var addAction = function() {
  $('.add-btn').click(function(e){
    e.preventDefault();

    var new_word = $('.single-word-rule-input.add').val();
    var new_word_intent = $('select.intents-options.add').val();

    var data = { "text": new_word, "intent_ref": "{{intent:"+new_word_intent+"}}" };

    $.ajax({
      type: 'POST',
      url: '/api/single_word_rules',
      data: data
    })
    .done(function(res){
      console.log( res );
      window.location.reload();
    })
    .fail(function(err){
      console.log( err );
    });
  });
};

var editAction = function() {
  $('.edit-btn').click(function(e){
    e.preventDefault();

    var this_row = $(this).closest('.single_word_row');

    // Pre select dropdown menu
    var current_intent = this_row.find('td')[1].innerHTML;
    this_row.find('option[value="'+current_intent+'"]').attr("selected", "selected");

    // Reset all td
    $('.single_word_row td').each(function(){
      var this_td = $(this);
      if ( this_td.hasClass("table-view") ){
        this_td.removeClass('displayNone');
      }
      if ( this_td.hasClass("input-view") ){
        this_td.addClass('displayNone');
      }
    });

    // Toggle clicked td
    this_row.find('td').each(function(){
      var this_td = $(this);
      if ( this_td.hasClass('displayNone') ){
        this_td.removeClass('displayNone');
      } else {
        this_td.addClass('displayNone');
      }
    });
  });
};

var saveAction = function() {
  $('.save-btn').click(function(e){
    e.preventDefault();

    var row_num          = $(this).parents().eq(1).data('index');
    var edit_word        = $(this).parents().eq(1).find('input').val();
    var edit_word_intent = $(this).parents().eq(1).find('select').val();

    var data = { "row_num": row_num, "text": edit_word, "intent_ref": "{{intent:"+edit_word_intent+"}}" };

    $.ajax({
      type: 'PUT',
      url: '/api/single_word_rules',
      data: data
    })
    .done(function(res){
      console.log( res );
      window.location.reload();
    })
    .fail(function(err){
      console.log( err );
    });
  });
};

$(document).on('turbolinks:load', function() {
  getData();
});
