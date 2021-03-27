  $(function () {

    if( $('#submissions').length > 0 ){

      // hide image preview unless user chooses to provide an image
      $('#place_image_placeholder').hide();
      $('#step_finished #place_image_placeholder').show();
      if (( $('#new_image #image_title').length > 0 ) &&  ( $('#image_title')[0].value.length > 0 )) {
        console.log( $('#image_title')[0].value.length );
        $('#place_image_placeholder').show();
      }
      $('#image_title').on('input change',function(){
        if ( this.value.length > 0 ) {
          console.log( this.value.length );
          $('#place_image_placeholder').show();
        } else {
          $('#place_image_placeholder').hide();
        }
      });
      // setup handler for form field changes
      var form_fields = ['submission_name', 'place_location', 'place_teaser', 'place_address', 'image_title'];
      form_fields.forEach(element => {
        if( $('#' + element).length > 0 && $('#' + element + '_receiver').length > 0 ) {
          // check on page load
          var value = $('#' + element).val();
          if ( !value.length > 0 ) {
              value = "&nbsp;"
          }
          $('#' + element + '_receiver').html(value);



          // check on input or change
          $('#' + element).on('input change',function(){
            var value = $( this ).val();
            if ( !value.length > 0 ) {
              value = "&nbsp;"
            }
            $('#' + element + '_receiver').html(value);
         });
        }
      });


      if ( $('textarea#place_teaser').length > 0 ) {
        var current_textarea_length = $('textarea#place_teaser')[0].value.length;
        if ( current_textarea_length > 1  ) {
          $('#place_teaser_counter').text(current_textarea_length);
        }
        if (current_textarea_length >= 450) {
          $('#place_teaser_counter').addClass('warning');
        }


        $('textarea#place_teaser').on('change keyup paste', function() {
            var len = this.value.length;
            if (len >= 450) {
              $('#place_teaser_counter').addClass('warning');
            } else {
              $('#place_teaser_counter').removeClass('warning');
            }
            if (len >= 500) {
              this.value = this.value.substring(0, 500);
            } else {
              $('#place_teaser_counter').text(len);
            }
        });
      }

      if( $('#image_upload').length > 0 ){
        //setup handler for image switch
        $('#image_upload').on('change',function(){
          if($( '#image_upload' ).is(':checked')) {
            $('#image_accordion').foundation('down',$("#image_form_item .accordion-content"));
            $('#place_image_placeholder').show();
          } else {
            $('#image_accordion').foundation('up',$("#image_form_item .accordion-content"));
            $('#place_image_placeholder').hide();
          }
        });
        $('#image_accordion').on('down.zf.accordion',function(){
            $('#place_image_placeholder').show();
            $( '#image_upload' ).prop('checked', true);
        });
        $('#image_accordion').on('up.zf.accordion',function(){
          $('#place_image_placeholder').hide();
          $( '#image_upload' ).prop('checked', false);
        });

      }

      if( $('#place_address').length > 0 ){

        $('input#place_address').on('keyup', function(e) {
            console.log('change', $(this).val())
            e.preventDefault();
            LookupCity($(this).val());
        });
        $('button#place_addresslookup_button').click(function(e) {
          e.preventDefault();
          var val = $('input#place_address').val();
          LookupCity(val);
        });
      }


    }
  });


  function LookupCity(address = '') {
    $.ajaxSetup({
      headers : {
        'User-Agent' : 'ORTE-Backend, in development (https://github.com/ut/ORTE-backend)',
        'crossDomain' : true,
        'Accept-Language' : $('#locale').val()
      }
    });
    $('.response-list').remove();
    $('#selection-hint').html('<p>Searching...</p>');
    var items = [];
    console.log("---------------------");
    console.log("LookupNominatim");
    console.log("Checking for params...");
    //var url = PrepareBeforeLookup(url);
    var url = '';
    if ( address === '' ) {
      $('#selection-hint').html("<p>" + I18n.t('search.lookup.no_input') +  "</p>");
      $('#selection-hint').addClass('active');
    }
    if ( address.length < 5 ) {
      console.log('Lookup:: Value too short!');
      $('#selection-hint').html("<p>" + I18n.t('search.lookup.too_short') +  "</p>");
      $('#selection-hint').addClass('active');
    } else {
      console.log('Lookup:: '+address);
      //example
      // https://nominatim.openstreetmap.org/search?q=135+pilkington+avenue,+birmingham&format=xml&polygon=1&addressdetails=1
      var nominatium_url = 'https://nominatim.openstreetmap.org/search';
      var nominatium_url_params = '&format=json&addressdetails=1&featuretype=city'

      var request = $.getJSON( nominatium_url+"?q="+address+nominatium_url_params, function( data ) {

          console.log(data);
          // if no result
          if ( !data || data.length === 0) {
            console.log('Lookup:: No result');
            $('#selection-hint').html("<p>" + I18n.t('search.lookup.no_result') +  "</p>");
            $('#selection-hint').addClass('active');
            return;
          }
          // if results
          console.log("items: "+items.length);
          console.log("response: "+$('#response').length);
          $('.response-list').remove();
          $.each( data, function( key, val ) {
            console.log('Lookup:: Data value class ' + val.class);
            var regexp = /amenity|building|highway|boundary/gi;
            var label = ''
            if ( val.class === 'building') {
              label = I18n.t('search.lookup.address');
            }
            var href = url+'?address='+val.display_name+'&lat='+val.lat+'&lon='+val.lon;

            // OR better get address details
            /*
            pub Café Treibeis
            house_number  25
            road  Gaußstraße
            suburb  Ottensen
            city_district Altona
            state Hamburg
            postcode  22765
            country Germany
            country_code  de
            */

            if ( val.address !== 'undefined') {
              var location = ''; var address= ''; var road = ''; var house_number = ''; var postcode = '';
              location = val.address[Object.keys(val.address)[0]];
              console.log("Lookup:: Location YEAH "+location);
              if ( typeof val.address.road !== 'undefined') {
                road = val.address.road;
                if ( typeof val.address.house_number !== 'undefined') {
                  house_number   = " "+val.address.house_number;
                  address = "&address="+road+" "+house_number;
                } else {
                  address = "&address="+road;
                }
              }
              if ( typeof val.address.postcode !== 'undefined') {
                postcode = "&postcode="+val.address.postcode;
              }
              var city = ''
              if ( val.address && val.address.city && (val.address.city !== 'undefined')) {
                city = val.address.city;
              } else {
                city = val.address.state
              }
              // TODO verify all values
              // FIXME hamburg as state
              href = url+'?'+location+address+postcode+"&city="+city+'&lat='+val.lat+'&lon='+val.lon;
            }


            if ( val.class.match(regexp) ) {
              console.log('Lookup:: Using entry');
              items.push( "<li id='" + key + "' class='nominatim_results' ><a href='return false;' data-zip='"+ postcode + "' data-city='"+ city + "' data-lat='"+ val.lat + "' data-lon='"+ val.lon + "' data-location='"+ label + " " + val.display_name + "'>" + label + " " + val.display_name + "</a></li>" );
            }
          });
          $( "<ul/>", {
            "id": "response",
            "class": "response-list",
            html: items.join( "" ),
          }).appendTo( "#selection" );

          console.log( "Success" );
          $('#selection-hint').html("<p>" + I18n.t('search.lookup.success_result') +  "</p>");
          $('#selection-hint').addClass('active');
        }).done(function() {
          $('.nominatim_results a').on('click', function(e){

            console.log( "Click" );
            e.preventDefault();
            var lat = $(this).data('lat');
            console.log( "Click", lat );
            $('#place_lat').val(lat);
            $('#place_lon').val($(this).data('lon'));
            $('#place_zip').val($(this).data('zip'));
            $('#place_city').val($(this).data('city'));
            $('#place_location').val($(this).data('location'));
            $('#place_address').val($(this).data('location'));
            $('#place_address_receiver').text($(this).data('location'));

            $('.response-list').remove();
            $('#selection-hint').html("");
          });
        }).fail(function() {
          console.log( "error" );
          $('#selection-hint').html("<p>" + I18n.t('search.lookup.nothing_found') +  "</p>");
          $('#selection-hint').addClass('active');
        }).always(function() {
          console.log( "Complete" );
        });
    }
  }