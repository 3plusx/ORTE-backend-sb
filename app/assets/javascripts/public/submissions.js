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
      
    } 
  });
