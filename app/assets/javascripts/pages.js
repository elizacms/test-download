function fillWrapperQueryAndClearPrevious(){
    var intent = $('select#intents').val();
    $('#wrapper_query').val(intent);

    $('.notes').removeClass('in');
    $('code.json').html('');
    $('#wrapper_query').closest('div').nextAll('div').each(function(){
      $(this).find('.text-input').val('')
    });
}
