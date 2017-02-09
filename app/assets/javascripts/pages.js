function fillWrapperQueryAndClearPrevious(){
    var intent = $('select#intents').val();
    $('#wrapper_query').val(intent);

    clearForms();
}

function clearForms(){
    $('.notes').removeClass('in');
    $('.copy-btn').removeClass('in');
    $('.codeArea').text('');
    $('.CodeMirror').remove();

    $('#wrapper_query').closest('div').nextAll('div').each(function(){
      $(this).find('.text-input').val('')
    });
}

$(document).ready(function(){
  $('.copy-btn').click(function(){
    copyToClipboard($(this).siblings('.codeArea'));
    var copyConfirm = $(this).siblings('.copyConfirm');
    copyConfirm.addClass('in');

    setTimeout(function(){
      copyConfirm.removeClass('in');
    }, 1000);
  });

  function copyToClipboard(element) {
    var $temp = $('<input>');
    $('body').append($temp);
    $temp.val(JSON.stringify( $(element).text(), null, 2 )).select();
    document.execCommand('copy');
    $temp.remove();
  }

  $('.test-btn').click(function(e){
      e.preventDefault();
      IAM.loading.start({ type:'logo', duration: false });

      var action = $(this).closest('form').attr('action');
      var inputText = $(this).closest('.row').find('.text-input');

      if (action === '/api/wrapper-query' || action === '/api/nlu-query'){
          if ( window.lastQuery !== undefined && window.lastQuery !== inputText.val() ){
              $(this).closest('.section').nextAll('.section').each(function(i, block){
                  $(this).find('.notes').removeClass('in');
                  $(this).find('.copy-btn').removeClass('in');
                  $(this).find('.codeArea').text('');
                  $(this).find('.CodeMirror').remove();
                  $(this).find('.text-input').val('');

                  window.lastQuery = inputText.val();
              });

              if ( action === '/api/wrapper-query' ){
                  $('#nlu_query').val(window.lastQuery);
              } else {
                  $('#wrapper_query').val( window.lastQuery );
                  $('#wrapper_query').closest('div').find('.notes').removeClass('in');
                  $('#wrapper_query').closest('div').find('.copy-btn').removeClass('in');
                  $('#wrapper_query').closest('div').find('.codeArea').text('');
                  $('#wrapper_query').closest('div').find('.CodeMirror').remove();
              }
          } else {
              window.lastQuery = $('#wrapper_query').val();
              $('#nlu_query').val(window.lastQuery);
          }
      }

      if ($(this).parents('.skill').length > 0) {
          var data = inputText.val();
      } else {
          var data = {};
          data[inputText.attr('name')] = inputText.val();
          data = JSON.stringify( data );
      }

      $.ajax({
          type: 'POST',
          dataType: 'json',
          headers: {
              'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
              'Content-Type': 'application/json',
              'X-Skill-Url':  $(this).parents('.row').find('.skill-url').val(),
              'X-Test-Env':   $('#intent_list_url').val()
          },
          url:  action,
          data: data
      }).done(function(r){
          var thisSection = $(this).closest('.section');

          stopLoadingAndReport(r, thisSection);

          if ( action === '/api/nlu-query' || action === '/api/skill-retrieve'){
              $('.skill').addClass('in');
              intentList(r['response'], r['access_token'], action);
          }
      }.bind(this)).fail(function(r){
          var thisSection = $(this).closest('.section');

          stopLoadingAndReport(r, thisSection);
      });
  });

  function intentList(response, token, action){
      $.ajax({
          type: 'POST',
          dataType: 'json',
          headers: {
              'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          },
          url: '/api/intents-list',
          data: $('#intent_list_url').serialize()
      }).done(response, token, action, function(intents){
          if ( action === '/api/nlu-query'){
              window.intent = JSON.parse( response )['intent'];
              window.mentions = JSON.parse( response )['mentions'];
              var skillUrl = JSON.parse( intents['response'] )[intent].split('.com')[0];

              var retrieveJSON = {};
              var nlu = retrieveJSON['nlu_response'] = {};
              var payload = nlu['payload'] = {};
              var user_data = payload['user_data'] = {};

              nlu['intent']   = intent;
              nlu['mentions'] = mentions;
              user_data['tokens'] = [{'provider': 'iamplus', 'value': token}];

              $('#skill_retrieve').val( JSON.stringify( retrieveJSON, null, 2 ) );
              $('#skill_retrieve_url').val( skillUrl + '.com/retrieve');
              $('#skill_format_url').val( skillUrl + '.com/format');
          } else if ( action === '/api/skill-retrieve' ){
              var formatJSON = {};
              var nlu = formatJSON['nlu_response'] = {};

              nlu['intent']   = intent;
              nlu['mentions'] = mentions;

              $('#skill_format').val( JSON.stringify( formatJSON, null, 2 ) );
          }
      });
  }

  function stopLoadingAndReport(r, section){
      $('.iam-loading').each(function(){
          IAM.loading.stop({id: $(this).attr('rel')});
      });

      var codeArea  = section.find('.codeArea')[0];
      var cm = CodeMirror.fromTextArea( codeArea, {
          lineNumbers: true,
          foldGutter: true,
          readOnly: true,
          gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
      });

      cm.setSize(null, 420);

      section.find('.codeArea').text(r['response']);
      cm.setValue(r['response']);

      section.find('.server-time').text( r['time'] );
      section.find('.url-used').text( r['url'] );
      section.find('.notes').addClass('in');
      section.find('.copy-btn').addClass('in');
  }
});
