


<html>
    <head>
        <title>IMOS AUV viewer</title>

        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'base.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'map.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'overcast/jquery-ui-1.8.5.custom.css')}"/>

        <meta name="layout" content="main" />

        <script type="text/javascript" src="${resource(dir:'js',file:'jquery-1.4.2.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'layout1.1.5.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'jquery-ui-1.8.5.custom.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'OpenLayers-2.9.js')}" ></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'auv-functions.js')}"  defer="defer"></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'stepcarousel.js')}"></script>


        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />


        <script type="text/javascript">


            var buff = 10;
            var server = '${server}';
            var layername_track = '${layernameTrack}';
            var layername_images = '${layernameImages}';

              // get the server name to choose proxy latter
             var this_serverName = '${serverName}'

            // get the bounds from geoserver
            var bounds = "" + (112.947 -buff) +","+ (-33.00 -buff)+","+(116.46 + buff)+","+ (0.874 + buff) ;



            var mapheight = '400';
            var mapwidth = '500';
            var tmptarget = "";
            var size = new OpenLayers.Size(30,24);
            var offset = new OpenLayers.Pixel(-(size.w/2)+5, -(size.h-1));
            //var offset = new OpenLayers.Pixel(-(size.w), -size.h);
            var icon = new OpenLayers.Icon('images/auv-marker.png',size,offset);
            //var slider = null; // slider object
            

            var style = 'AUV_tracks';


            jQuery(document).ready(function(){

                // set map container size before map exists with jQuery
                jQuery("#map").height(mapheight);
                jQuery("#map").width(mapwidth);
                jQuery("#wrapper").width(mapwidth);






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
                jQuery("#legendToggle").click(function() {
                    jQuery('div#legend').toggle();
                });
                jQuery("#legendClose").click(function() {
                    jQuery('div#legend').hide();
                });

                jQuery('button').mouseover(function() {
                    jQuery(this).addClass('hover');
                });
                jQuery('button').hover(function() {
                        jQuery(this).addClass('hover');
                    },function() {
                        jQuery(this).removeClass('hover');
                });
                jQuery('#legend').jqDrag();

                jQuery('#trackSelector').change(function() {
                    if (jQuery(this).val() != "default") {
                        populateTracks();
                        allTracksSelector("#" + jQuery(this).val());
                    }
                });

                // live will attach events to objects now and in the future
                // track_html contents
                jQuery('.getfeatureTitle').live('mouseover', function() {
                    // change class
                    jQuery(this).addClass('.a_hover');
                });
                jQuery('.getfeatureTitle').live('click', function() {

                    var code = jQuery(this).siblings('.getfeatureCode').text();
                    var extent = jQuery(this).siblings('.getfeatureExtent').text();
                    showHideZoom(code,extent);
                });

                jQuery('#slider').slider({
                    animate: 'normal',
                    min: 1,
                    stop: function(event, ui) {
                        var val = jQuery(this).slider( "value" );

                        stepcarousel.moveTo('mygallery', val);
                        jQuery('#slider').slider( "disable" );

                    }

                });


                // http://code.google.com/p/css-template-layout/
                jQuery.setTemplateLayout('css/map.css?', 'jq');
                jQuery('#loader').hide(3000);
                //jQuery('#mainbody').css('visibility','visible').delay(8000).fadeIn(400);;
                mapinit(bounds,mapheight,mapwidth);





            });


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

                    if (target.tagName=="IMG") { //if clicked on element is an image
                      
                        openPopup(target.src);
                    }
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

                    jQuery('[id^=auvpanel]').css('background-color','inherit');
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
                    jQuery.setTemplateLayout('css/map.css?', 'jq');

                    jQuery('#slider').slider( "enable" );


                }

            })

 </script>

    </head>
    <body>


    <div id="mainbody"  >

        <div id="trackcontainer">
            <div id="trackSelectorDiv" >
                <select name="trackSelector" id="trackSelector">
                    <option id="default" value="default" >... Choose a AUV Track... </option>
                </select>
            </div>
            <div id="track_html"></div>
        </div>
        <div id="mapcontainer">
           
          <h1 class="align-right" >Autonomous Underwater Vehicle Image Viewer &nbsp;</h1>
            <div id="mapWrapper" class="align-right">
                <div id="map">
                    <div id="controlPanZoom" ></div>
                </div>
            </div>
          <div style="clear:both" ></div>
            <div id="controlWrapper"  >
                <div id="mapscale"></div>
                <div id="mapcoords">location</div>
                <div id="legendToggle">Legend</div>
                <div id="legend" class="jqDnR jqDrag" style="display:none">
                    <img id="legendClose" alt="Close popup" class="right" src="images/close.png" />
                    <img src="${server}/geoserver/wms?LAYER=${layernameTrack}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" alt="Legend for ${layernameTrack}" /><BR>
                    <img src="${server}/geoserver/wms?LAYER=${layernameImages}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" alt="Legend for ${layernameImages}" />
                </div>
                <div id="styles"  style="display:none">
                    <a>Styles:</a>
                    <select id="imageFormatSelector" onchange="setStyle(value)">
                        <option value="">Default</option>
                          <option value="auv_images_temperature">Temperature</option>
                    </select>

                </div>


            </div>
        </div>

        <div id="imagecontainer">

            <div id="helpSection" >
              <h3>How to use this AUV image viewer</h3>
                
                   
                    
                   <ol>
                        <li>Click on a AUV Icon, or choose from the track list on the left.
                        <li> Choose a track and the map will zoom to it.
                        <li> Click on a track to view the closest images to the click origin.
                        <li> Optionally sort images along the track for the currently highlighted image.
                        <li> Click on any image to view or add notes about the image contents.
                    </ol>
            </div>
            <div id="mygallery" class="stepcarousel">

            
                <div class="belt">
                    <div class="panel">
                        <images src="images/mapshadow.png" />
                    </div>
                </div>
            </div>
            <div id="stepcarouselcontrols">
                <p id="unsorted_status">
                    <b>Current Viewing Images:</b> <span id="statusA"></span> to <span id="statusB"></span><b>of:</b> <span id="statusC"></span> <b>near your click point</b>
                </p>
                <p id="sorted_status"></p>


                <div class="trackSort"><a href="javascript:sortImagesAlongTrack('left')">Older</a></div>
                &nbsp;
                <div id="sliderContainer" >
                    <div id="slider"></div>
                </div>
                <div class="trackSort">&nbsp;<a href="javascript:sortImagesAlongTrack('right')">Later</a></div>



                <div id="stepcarouselreorder"></div>

                <div id="imageInfo" style="display:none" >
                    <p>image name: <font id="this_image_filename"></font></p>
                    <p>image site_code: <font id="this_site_code"></font></p>
                    <p>fk_auv_tracks: <font id="this_fk_auv_tracks"></font></p>
                </div>




            </div>

            <div class="buttons"  >
                <h3 id="thisTrackInfo"></h3>
                <button  href="#" onclick="sortImagesAlongTrack();return false;" id="sortbytrack" style="display:none" >Sort the Images along the<span> selected</span> track</button>
                <button onclick="resetMap()" id="resetmap" >RESET MAP</button>
            </div>

            <div id="footer">
                <DIV id="logo">
                <a href="http://imos.org.au/auv.html"><img src="images/IMOS_AUV_logo.png" /></a>

            </div>
                <p><a href="http://www.imos.org.au" title="Integrated Marine Observing System">IMOS</a> is supported by the Australian Government through the
                <a href="http://www.innovation.gov.au/Section/AboutDIISR/FactSheets/Pages/NationalCollaborativeResearchInfrastructureStrategy%28NCRIS%29FactSheet.aspx">
                National Collaborative Research Infrastructure Strategy</a>
                and the Super Science Initiative.<br>
                You accept all risks and responsibility for losses, damages, costs and other consequences resulting directly or indirectly from
                using this site and any information or material available from it. <br>Please read our policy regarding the
                'Acknowledgement of Use of IMOS Data' at <a href="http://imos.org.au/emii_data.html" target="_blank">http://imos.org.au/emii_data.html</a><br>
                <a href="http://imos.org.au/emii.html" title="eMarine Information Infrastructure">Created by eMII</a> &nbsp;
                <a href="http://www.imos.org.au" title="Integrated Marine Observing System">&copy; IMOS Australia</a>  &nbsp;
                Comments on this site? Contact us at <a href="mailto:info@emii.org.au">info@emii.org.au</a></p>

            </div>

        </div>






 </div>
 <div id="loader"  >
        <img alt="loading..." src="images/loading.gif" >
    </div>

</body>

</html>
