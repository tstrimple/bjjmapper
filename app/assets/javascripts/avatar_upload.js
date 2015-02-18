+function() {
  $(document).ready(function() {
    $('body').delegate('[data-upload-avatar]', 'change', function(e) {
      console.log('starting ajax file upload');

      var files = e.currentTarget.files;
      var team = $(e.currentTarget).data('id');

      var data = new FormData();
      data.append('file', files[0]);

      $.ajax({
        url: '/service/avatar/upload/teams/' + team + '/async',
        type: 'POST',
        cache: false,
        dataType: 'html',
        processData: false,
        contentType: false,
        data: data,
        success: function() {
          toastr.success('Image processing may take a few minutes. Please check back soon.', 'Image successfully uploaded');
        },
        error: function() {
          toastr.error('Please try again later. If you believe this to be a bug, please email us at info@bjjmapper.com', 'Image upload failed');
        }
      })
    });
  });
}();
