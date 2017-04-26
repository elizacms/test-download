function fillWrapperQueryAndClearPrevious(){
    var intent = $('select#intents').val();
    $('#wrapper_query').val(intent);

    clearForms();
}

function clearForms(){
    $('.notes').removeClass('in');
    $('.copyBtnMain').removeClass('in');
    $('.codeArea').text('');
    $('.CodeMirror').remove();

    $('#wrapper_query').closest('div').nextAll('div').each(function(){
      $(this).find('.text-input').val('');
    });
}

$(document).on('turbolinks:load', function(){
  $('.copyBtnMain').click(function(){
    copyToClipboard($(this).siblings('.codeArea'), $(this).siblings('.copyConfirm'));
  });

  $('.copyBtnCurl').click(function(){
    copyToClipboard($(this).parents('.modal-body').find('.modalCode'), $(this).siblings('.copyConfirm') );
  });

  function copyToClipboard(element, confirmElement) {
    var $temp = $('<textarea>');

    if (element.parents('.modal').length > 0){
      element.parents('.modal-body').append($temp);
    }
    else {
      $('body').append($temp);
    }

    $temp.text(element.text()).select();
    document.execCommand('copy');
    $temp.remove();

    confirmElement.addClass('in');
    setTimeout(function(){
      confirmElement.removeClass('in');
    }, 1000);
  }

  $('.test-btn').click(function(e){
      e.preventDefault();
      IAM.loading.start({ type:'logo', duration: false });

      var action      = $(this).closest('form').attr('action');
      var inputText   = $(this).closest('.row').find('.text-input');
      var thisSection = $(this).closest('.section');

      if (thisSection.find('.responseCodeMirror').length > 0) {
          thisSection.find('.responseCodeMirror').remove();
      }

      if (action === '/api/wrapper-query' || action === '/api/nlu-query'){
          if ( window.lastQuery !== undefined && window.lastQuery !== inputText.val() ){
              $(this).closest('.section').nextAll('.section').each(function(i, block){
                  $(this).find('.notes').removeClass('in');
                  $(this).find('.copyBtnMain').removeClass('in');
                  $(this).find('.codeArea').text('');
                  $(this).find('.CodeMirror').remove();
                  $(this).find('.text-input').val('');
                  $(this).find('.modalCode').text('');

                  window.lastQuery = inputText.val();
              });

              if ( action === '/api/wrapper-query' ){
                  $('#nlu_query').val(window.lastQuery);
              } else {
                  $('#wrapper_query').val( window.lastQuery );
                  $('#wrapper_query').closest('div').find('.notes').removeClass('in');
                  $('#wrapper_query').closest('div').find('.copyBtnMain').removeClass('in');
                  $('#wrapper_query').closest('div').find('.codeArea').text('');
                  $('#wrapper_query').closest('div').find('.CodeMirror').remove();
                  $('#wrapper_query').closest('div').find('.modalCode').text('');
              }
          } else {
              if ($('#wrapper_query').val() === ''){
                  window.lastQuery = $('#nlu_query').val();
                  $('#wrapper_query').val(window.lastQuery);
              }
              else {
                  window.lastQuery = $('#wrapper_query').val();
                  $('#nlu_query').val(window.lastQuery);
              }
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

          if ( action === '/api/nlu-query' || action === '/api/skill'){
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
              nlu['mentions'] = groomMentions(mentions);
              user_data['tokens'] = [{'provider': 'iamplus', 'value': token}];

              var r = JSON.stringify( retrieveJSON, null, 2 );
              $('#skill_retrieve'    ).val( r );
              $('#skill_retrieve_url').val( skillUrl + '.com/retrieve');
              $('#skill_format_url'  ).val( skillUrl + '.com/format');

              createAndPopulateCodeMirror(r, $('.skill-retrieve'), '.text-input-retrieve', false, true );
              console.log('retrieve');
          } else if ( action === '/api/skill' ){
              var formatJSON = {};
              var nlu = formatJSON['nlu_response'] = {};

              nlu['intent']   = intent;
              nlu['mentions'] = mentions;

              r = JSON.stringify( formatJSON, null, 2 );
              $('#skill_format').val( r );

              if ($('.skill-format').find('.requestCodeMirror').length === 0) {
                createAndPopulateCodeMirror(r, $('.skill-format'), '.text-input-format', false, true );
              }
          }
      });
  }

  function groomMentions( mentions ){
      if (mentions.length == 1 && 'entity' in mentions[0]){
          return [];
      } else if ( mentions.length == 1 && (!('entity' in mentions[0])) ) {
          return mentions;
      }

      var groomedMentions = [];

      mentions.map(function(mention, index){
          if (mention['type'].match('list') == null){
              groomedMentions.push(mention);
          }
      });

      return groomedMentions;
  }

  function stopLoadingAndReport(r, section){
      $('.iam-loading').each(function(){
          IAM.loading.stop({id: $(this).attr('rel')});
      });

      createAndPopulateCodeMirror(r['response'], section, '.codeArea', true, false);
      populateCurlCommandModal(r, section);

      section.find('.codeArea'   ).text( r['response'] );
      section.find('.server-time').text( r['time'] );
      section.find('.url-used'   ).text( r['url'] );
      section.find('.notes'      ).addClass('in');
      section.find('.copyBtnMain').addClass('in');
  }

  function populateCurlCommandModal(r, section){
      var curlCommand = 'curl -X POST -H "Content-Type: application/json" -d ' + "'" +
      r['details'].replace(/,/g, ',<br>' ).replace(/{/g, '{<br>').replace(/}}/g, '}<br>}')
      + "'" + ' "' + r['url'] + '"';

      section.find('.modalCode').html(curlCommand);
  }

  function createAndPopulateCodeMirror(r, section, textArea, readOnly, requestText){
      var codeArea = section.find(textArea)[0];
      var cm = CodeMirror.fromTextArea( codeArea, {
          lineNumbers: true,
          foldGutter:  true,
          readOnly:    readOnly,
          gutters:     ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
      });

      cm.setSize(null, 420);
      cm.setValue(r);

      if (requestText) {
          $(codeArea).siblings('.CodeMirror').addClass('requestCodeMirror');
      }
      else {
          $(codeArea).siblings('.CodeMirror').addClass('responseCodeMirror');
      }
  }
});
