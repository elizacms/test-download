var buildStopWordsTable = function(data) {
  data.forEach(function(d, index){
     $('#stopWordsTable').append( '<tr class="stop-words-row" data-index="'+index+'">'
                                +   '<td class="stop-words-table-view" >'
                                +     d[0]
                                +   '</td>'
                                +   '<td class="stop-words-table-view stop-words-edit-save-btn">'
                                +     '<a href="#" class="edit-stop-words-btn hide-visibility btn md grey">Edit</a>'
                                +   '</td>'

                                +   '<td class="stop-words-input-view displayNone">'
                                +     '<input type="text" class="stop-words-input" value="'+d[0]+'"/>'
                                +   '</td>'
                                +   '<td class="stop-words-input-view stop-words-edit-save-btn displayNone">'
                                +     '<a href="#" class="save-stop-words-btn btn md black">Save</a>'
                                +   '</td>'
                                + '</tr>'
                                );
  });
};

var checkStopWordsLock = function() {
  $.ajax({
    type: 'GET',
    url:  '/api/stop_words/check_lock'
  })
  .done(function(res){
    if (res.is_locked == false){
      $('.edit-stop-words-btn').removeClass("hide-visibility");
    } else {
      $('.edit-stop-words-btn').addClass("hide-visibility");
    }
  })
  .fail(function(err){
    console.log( err );
  })
};

var addStopWordsAction = function() {
  $('.add-stop-words-btn').click(function(e){
    e.preventDefault();

    var newStopWords = $('.stop-words-input.add').val();
    var data = { "text": newStopWords };

    $.ajax({
      type: 'POST',
      url: '/api/stop_words',
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

var editStopWordsAction = function() {
  $('.edit-stop-words-btn').click(function(e){
    e.preventDefault();

    var this_row = $(this).closest('.stop-words-row');

    // Reset all td
    $('.stop-words-row td').each(function(){
      var this_td = $(this);
      if ( this_td.hasClass("stop-words-table-view") ){
        this_td.removeClass('displayNone');
      }
      if ( this_td.hasClass("stop-words-input-view") ){
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

var saveStopWordsAction = function(){
  $('.save-stop-words-btn').click(function(e){
    e.preventDefault();

    var row_num       = $(this).parents().eq(1).data('index');
    var editStopWords = $(this).parents().eq(1).find('input').val();

    var data = { "row_num": row_num, "text": editStopWords };
    
    $.ajax({
      type: 'PUT',
      url: '/api/stop_words',
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

var getStopWordsData = function() {
  $.ajax({
    type: 'GET',
    url: '/api/stop_words',
    dataType: "json",
    headers: {
      'Accept': 'application/json'
    }
  })
  .done(function(data){
    buildStopWordsTable(data);

    checkStopWordsLock();

    addStopWordsAction();

    editStopWordsAction();

    saveStopWordsAction();
  })
  .fail(function(err){
    console.log( err );
  });
};

$(document).on('turbolinks:load', function() {
  getStopWordsData();
});