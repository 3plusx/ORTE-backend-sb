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
      
    } 
  });
