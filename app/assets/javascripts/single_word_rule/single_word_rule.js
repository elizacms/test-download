var appendOptions = function(intents) {
  intents.forEach(function(intent){
    $('.intents-options').append('<option value="'+intent+'">'+intent+'</option>');
  });
};

var getAllIntents = function() {
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

var addAction = function() {
  $('.add-btn').click(function(e){
    e.preventDefault();
    console.log( "Add this." );
    var new_word = $('.single-word-rule-input.add').val();
    var new_word_intent = $('select.intents-options.add').val();
    console.log( new_word );
    console.log( new_word_intent );
  });
};

var editAction = function() {
  $('.edit-btn').click(function(e){
    e.preventDefault();

    var this_row = $(this).closest('.single_word_row');

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
    console.log( "Save this." );
    var edit_word =  $(this).parents().eq(1).find('input').val();
    var edit_word_intent = $(this).parents().eq(1).find('select').val();
    console.log( edit_word );
    console.log( edit_word_intent );
  });
};


$(document).on('turbolinks:load', function() {
  getAllIntents();

  addAction();

  editAction();

  saveAction();
});
