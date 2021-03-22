  $(function () {

    if( $('#submissions').length > 0 ){
      // setup handler for form field changes
      var form_fields = ['submission_name', 'place_location', 'place_teaser'];
      form_fields.forEach(element => {
        if( $('#' + element).length > 0 && $('#' + element + '_receiver').length > 0 ) {
          
          $('#' + element).on('input',function(){
            var value = $( this ).val();
            $('#' + element + '_receiver').text(value)
         });
        }  
      });

      if( $('#image_upload').length > 0 ){
        //setup handler for image switch
        $('#image_upload').on('change  changed.zf.slider',function(){
          if($( this ).is(':checked')) {
            $('#image_accordion').foundation('down',$("#image_form_item .accordion-content"));
          } else {
            $('#image_accordion').foundation('up',$("#image_form_item .accordion-content"));
          }
        });
      }

      if( $('#place_address').length > 0 ){
      
        $('input#place_address').change(function(e) {
            e.preventDefault();
            LookupNominatim($(this).val(),$(this).data('url'));
        });
        $('button#addresslookup_button').click(function(e) {
          e.preventDefault();
          var val = $('input#place_address').val();
          LookupNominatim(val,$('input#place_address').data('url'));
        });
      }

      
    } 
  });
