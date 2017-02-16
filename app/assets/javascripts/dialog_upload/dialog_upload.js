$(document).on('turbolinks:load', function(){
  $('#files').change(function(){
    $('.upload-files').addClass('in');

    if ($('.result-section').length > 0){
      $('.result-section').removeClass('in');
    }

    $.each(this.files, function(index, file){
      $('.upload-table-data').append( '<tr><td>' + escape(file.name) + '</td></tr>' );
    });
  });

  $('.save-dialogs').click(function(e){
    e.preventDefault();
    IAM.loading.start({ type:'logo', duration: false });

    $('.upload-files').removeClass('in');

    var files = $('#files')[0].files;
    uploadFiles(files);

    $('.iam-loading').each(function(){
        IAM.loading.stop({id: $(this).attr('rel')});
    });

    var uploaderInput = $('#files');
    uploaderInput.wrap('<form>').closest('form')[0].reset();
    uploaderInput.unwrap();

    $('.upload-table-data').html('');
  });

  function updateView(){
    if (localStorage.length > 0) {
      $('.result-section').addClass('in');
      $.each(localStorage, function(key, value){
        $('.result-table-data').append(
          '<tr class="text-' +
          ((!value.includes('failed') && !value.includes('error')) ? 'success' : 'danger')
          + '"><td>' + key + '</td><td>' + value + '</td></tr>'
        );

        localStorage.removeItem( key );
      });
    }
  }

  function uploadFiles(files){
    $.each(files, function(index, file){
      var reader = new FileReader();
      reader.readAsText(file);

      reader.onloadend = postFile(file);
    });
  }

  function postFile(file){
    return (function() {
      $.ajax({
        type: 'POST',
        url: '/api/process_dialog_upload',
        headers: {
            'Accept' : 'text/csv; charset=utf-8',
            'Content-Type': 'text/csv; charset=utf-8'
        },
        data: this.result
      }).done(function(r){
        localStorage.setItem( file['name'], r.response );
      }).fail(function(r){
        localStorage.setItem( file['name'], r.statusText );
      }).always(function(){
        updateView();
      });
    });
  }
});
