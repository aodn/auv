<script>

            var buff = 10;
            var server = '${server}';
            var layername_track = '${layernameTrack}';
            var layername_images = '${layernameImages}';

              // get the server name to choose proxy latter
             var this_serverName = '${serverName}';

            // **********************************************************************************  get the bounds from geoserver
            var bounds = "" + (112.947 -buff) +","+ (-33.00 -buff)+","+(116.46 + buff)+","+ (0.874 + buff) ;



            var mapheight = '300';
            var mapwidth = '400';
            var tmptarget = "";
            var size = new OpenLayers.Size(30,24);
            var offset = new OpenLayers.Pixel(-(size.w/2)+5, -(size.h-1));
            //var offset = new OpenLayers.Pixel(-(size.w), -size.h);
            var icon = new OpenLayers.Icon('images/auv-marker.png',size,offset);
            //var slider = null; // slider object


            //var style = 'AUV_tracks';


            jQuery(document).ready(function(){


                // set map container size before map exists with jQuery
                jQuery("#map").height(mapheight);
                jQuery("#map").width(mapwidth);


                // highlight for the scale and lonlat info
                function onOver(){
                    jQuery("div#mapinfo ").css("opacity","0.9");
                }
                function onOut(){
                    jQuery("div#mapinfo ").css("opacity","0.5");
                }

                //jQuery("div#mapinfo ").css("opacity","0.5");
                jQuery("div#mapinfo ").css("opacity","0.5");
                jQuery("div#mapinfo").hover(onOver,onOut);

                // map legend show and hide
                jQuery("#legendToggle").click(function() {
                    jQuery('div#legend').toggle();
                });
                jQuery("#legendClose").click(function() {
                    jQuery('div#legend').hide();
                });
                jQuery('#legend').jqDrag(); // draggable popup like thingy. Nice


                jQuery('#styleSliderContainer').jqDrag(); // draggable popup like thingy. Nicer




                jQuery('button').mouseover(function() {
                    jQuery(this).addClass('hover');
                });
                jQuery('button').hover(function() {
                        jQuery(this).addClass('hover');
                    },function() {
                        jQuery(this).removeClass('hover');
                });



                // when user selects track from dropdown
                jQuery('#trackSelector').change(function() {
                    if (jQuery(this).val() != "default") {
                        resetStyleSelect(); // reset the style selector to default
                        allTracksSelector("#" + jQuery(this).val());
                    }
                });

                // track_html contents hyperlink on title
                // live will attach events to objects now and in the future
                jQuery('.getfeatureTitle').live('mouseover', function() {
                    // change class
                    jQuery(this).addClass('.a_hover');
                });
                jQuery('.getfeatureTitle').live('click', function() {

                    var code = jQuery(this).siblings('.getfeatureCode').text();
                    var extent = jQuery(this).siblings('.getfeatureExtent').text();
                    showHideZoom(code,extent);
                });

                // slider to change images
                jQuery('#slider').slider({
                    animate: 'normal',
                    min: 1,
                    stop: function(event, ui) {
                        var val = jQuery(this).slider( "value" );

                        stepcarousel.moveTo('mygallery', val);
                        jQuery('#slider').slider( "disable" );

                    }

                });
                // Allow left and right keys to control slider
                /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NOT WORKING YET
                jQuery(document.documentElement).keypress(function(e) {
                    var code = (e.keyCode ? e.keyCode : e.which);
                    var direction = null;

                    // handle cursor keys
                    if (code == 37) { // left key
                        direction = 'prev';
                    }
                    else if (code == 39) { // right key
                        direction = 'next';
                    }

                    if (direction != null && keyPressCheck() ) {
                        jQuery('#slider')[direction]().click();
                    }
                });
                */


                resetStyleSelect(); // reset the style selector to default


               // showLoader(false);
                //jQuery('#mainbody').css('visibility','visible').delay(8000).fadeIn(400);;
                mapinit(bounds,mapheight,mapwidth);

                <g:if test="${flash.zoom}" >

                 map.setCenter(new OpenLayers.LonLat(${flash.lon},${flash.lat}), 16);

                </g:if>


                // populate the track dropdown select and hidden track info
                // depends on the mapinits openlayers.proxyhost
                populateTracks();

                // then set layout with the map initialised
                jQuery('#mainbody').layout({
                  //applyDefaultStyles: true,
                  resizable: true,

                  /*defaults: {
                     center__minWidth:		400,
                     initClosed:            false
                  },*/
                  west: {
                    //applyDefaultStyles: true,
                    minSize: 410,
                    closable:  false
                   }
                 });

                 jQuery('#galleryControls').layout({
                     applyDefaultStyles: true,
                     west: {
                       minSize: 250
                     }
                 });


                jQuery('.trackSort').hide();

                //////////////////////////////////////////////////////////////// TESTing
                //var bbox = map.getExtent().toBBOX();
                //var res = setValuesForBBox(bbox,"depth");
                //alert(res);

                // hide the gallery. needs to exist for step carousel
                jQuery('#mygallery, #stepcarouselcontrols').toggle(false);

                // hide the cover over the ugly load
                jQuery('#loading_cover').fadeOut();





            }); // end jQuery(document).ready(function()

            // timer for jquery slider finction
            var checkTime = 0;
            function keyPressCheck(){
                var currentTime = new Date()
                if((currentTime.getTime() - checkTime) > 1000){
                    checkTime =currentTime.getTime();
                    return true;
                }
                else {
                    return false;
                }
            }

           stepcarousel.setup({
                galleryid: 'mygallery', //id of carousel DIV
                beltclass: 'belt', //class of inner "belt" DIV containing all the panel DIVs
                panelclass: 'panel', //class of panel DIVs each holding content
                autostep: {enable:false, moveby:1, pause:3000},
                panelbehavior: {speed:4500, stepbyspeed:400, wraparound:false, wrapbehavior:'slide', persist:false},
                defaultbuttons: {enable: false, moveby: 1, leftnav: ['images/buttonclose.png', 10, 10], rightnav: ['images/buttonopen.png', 10, 10]},
                statusvars: ['statusA', 'statusB', 'statusC'], //register 3 variables that contain current panel (start), current panel (last), and total panels
                contenttype: ['inline'], //content setting ['inline'] or ['ajax', 'path_to_external_file']
                onpanelclick:function(target){

                    //if (target.tagName=="IMG") { //if clicked on element is an image

                       // openPopup(target.src,siteCode);
                    //}
                },

                onslide:function(){

                    var html = "";
                    var targetpanel = jQuery('#statusA').text().trim()-1;
                    // set form for ordering images by tracks
                    html = jQuery('div#auvpanelinf_'+ targetpanel + ' .fk_auv_tracks').text().trim();
                    jQuery('#this_fk_auv_tracks').html(html);
                    html = jQuery('div#auvpanelinf_'+ targetpanel + ' .site_code').text().trim();
                    jQuery('#this_site_code').html(html);
                    html = jQuery('div#auvpanelinf_'+ targetpanel + ' .site').text().trim();
                    jQuery('#sortbytrack span').html("<br>" + ucwords(html));
                    html = jQuery('div#auvpanelinf_'+ targetpanel + ' .image_filename').text().trim();
                    jQuery('#this_image_filename').html(html);

                    // highlight the current selected slide (first left)
                    jQuery('[id^="auvpanel_"]').css('background-color','transparent');
                    jQuery('#auvpanel_' + targetpanel).css('background-color','#3399CC');

                    // add/move marker
                    var lon = jQuery('div#auvpanelinf_'+ targetpanel + ' .lon').text().trim();
                    var lat = jQuery('div#auvpanelinf_'+ targetpanel + ' .lat').text().trim();
                    if (lon != "") {
                        var halfIcon = icon.clone();
                        markers.clearMarkers();
                        markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(lon,lat),halfIcon));

                    }
                    jQuery('#navButtonL, #navButtonR').show();

                    jQuery('#slider').slider( "enable" );




                }

            });


</script>