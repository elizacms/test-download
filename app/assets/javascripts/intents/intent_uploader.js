$(document).on('turbolinks:load', function(){
  updateUI();

  $('#files').change(function(){
    $('.upload-files').addClass('in');

    if ($('.result-section').length > 0){
      $('.result-section').removeClass('in');
    }

    $.each(this.files, function(index, file){
      $('.upload-table-data').append( '<tr><td>' + escape(file.name) + '</td></tr>' );
    });
  });

  $('.save-intents').click(function(e){
    e.preventDefault();
    IAM.loading.start({ type:'logo', duration: false });

    var files = $('#files')[0].files;
    uploadFiles(files);

    setTimeout(function(){
      location.reload();
    }, 1200);
  });

  function uploadFiles(files){
    $.each(files, function(index, file){
      var reader = new FileReader();
      reader.readAsText(file);

      var result = this.result;

      reader.onloadend = postFile(file);
    });
  }

  function postFile(file){
    return (function(e) {
      var data = JSON.parse(this.result);
      data['skill_id'] = $('#skill_id').val();

      $.ajax({
        type: 'POST',
        url: '/api/process_intent_upload',
        dataType: 'json',
        data: data
      }).done(function(r){
        var text = r['response'];
        localStorage.setItem( file.name, text );
      }).fail(function(r){
        var text = JSON.parse( r.responseText )['response'];
        localStorage.setItem( file.name, text );
      })
    });
  }

  function updateUI(){
    if (localStorage.length > 0) {
      $('.result-section').addClass('in');
      $.each(localStorage, function(key, value){
        $('.result-table-data').append(
          '<tr class="text-' +
          (value.match('uploaded') ? 'success' : 'danger')
          + '"><td>' + key + '</td><td>' + value + '</td></tr>'
        );

        localStorage.removeItem( key );
      });
    }
  }
});
