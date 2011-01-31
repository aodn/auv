


<html>
    <head>
        <title>IMOS AUV Images Viewer</title>

        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'base.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'map.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'overcast/jquery-ui-1.8.5.custom.css')}"/>

        <meta name="layout" content="main" />

        <script type="text/javascript" src="${resource(dir:'js',file:'jquery-1.4.2.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'jquery.layout1.3.0.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js',file:'jqDnR.js')}"></script>
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
                // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NOT WORKING YET
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



                resetStyleSelect(); // reset the style selector to default


               // showLoader(false);
                //jQuery('#mainbody').css('visibility','visible').delay(8000).fadeIn(400);;
                mapinit(bounds,mapheight,mapwidth);

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

    </head>
    <body>


       <div id="loading_cover"></div>




      <!--div id="mainbodyPadding" -->
        

        <div id="mainbody"  >
    
             <div id="logo"   class="ui-layout-north" >
            <a href="http://imos.org.au/auv.html"><img src="images/IMOS_AUV_logo.png"  height="70" width="403" alt="IMOS Logo" /></a>
            <div class="toplinks">
                    <g:if test="${session.username}">
                           <g:link   controller="login" action="logout">logout</g:link> ${session.username}
                    </g:if>
                     <g:else>
                          <a  href="login" title="Login and view your stored searches and maps" class="leftmenu_ahref " >Login</a>
                     </g:else>


                    <a target="_blank" href="http://www.emii.org.au"  title="e-Marine Information Infrastructure" class="leftmenu_ahref " >eMII Home</a>
                    <a target="_blank" href="http://www.imos.org.au" title="Integrated Marine Observing System" class="leftmenu_ahref " >IMOS Home</a>
            </div>
            <h1>Autonomous Underwater Vehicle Images Viewer</h1>




   </div>
          



        <div id="mapcontainer" class="ui-layout-west">
          
           
          
            <div id="mapWrapper">
                <div id="map">
                    <div id="controlPanZoom" ></div>
                </div>
            </div>
            <div id="controlWrapper"  >
                <div id="mapscale"></div>
                <div id="mapcoords"></div>
                <div id="styles"  style="display:none">
                    <select id="imageFormatSelector" onchange="openStyleSlider(value)" onFocus="removeDefaultOption()">
                      <option class="defaultLabel" selected="selected">Image layer Style</option>
                        <option value="default"  >Default</option>
                          <option value="bathy" >Bathymetry</option>
                          <option value="temperature" >Temperature</option>
                    </select>
                   

                </div>
                <div id="legendToggle">Legend</div>
                
                


            </div>

             

              <div id="footer" >
              <a href="http://www.imos.org.au" title="Integrated Marine Observing System">IMOS</a> is supported by the Australian Government through the
              <a href="http://www.innovation.gov.au/Section/AboutDIISR/FactSheets/Pages/NationalCollaborativeResearchInfrastructureStrategy%28NCRIS%29FactSheet.aspx">
              National Collaborative Research Infrastructure Strategy</a>
              and the Super Science Initiative.
              You accept all risks and responsibility for losses, damages, costs and other consequences resulting directly or indirectly from
              using this site and any information or material available from it. Please read our policy regarding the
              'Acknowledgement of Use of IMOS Data' at <a href="http://imos.org.au/emii_data.html" target="_blank">http://imos.org.au/emii_data.html</a>
              <a href="http://imos.org.au/emii.html" title="eMarine Information Infrastructure">Created by eMII</a> &nbsp;
              <a href="http://www.imos.org.au" title="Integrated Marine Observing System">&copy; IMOS Australia</a>  &nbsp;
              Comments on this site? Contact us at <a href="mailto:info@emii.org.au">info@emii.org.au</a>
          </div>

          

          
        </div>


        <div id="imagecontainer" class="ui-layout-center" >

            <div id="helpSection" >
              <h3>How to use this AUV image viewer</h3> 
                    
                   <ol>
                        <li>Click on a AUV Icon, or choose from the track list.
                        <li> Choose a track and the map will zoom to it.
                        <li> Click on a track to view the closest images to the click origin.
                        <li> Optionally sort images along the track for the currently highlighted image.
                        <li> Click on any image to view or add notes about the image contents.
                    </ol>
            </div>
            <div id="mygallery" class="stepcarousel">

            
                <div class="belt">
                    <div class="panel">
                        <img src="images/mapshadow.png" />
                    </div>
                </div>
            </div>

           <div id="galleryControls" style="height:360px" >
                <div id="trackSelectorDiv" class="ui-layout-north buttons" >
                    <select name="trackSelector" id="trackSelector">
                        <option id="default" value="default" >... Choose a AUV Track... </option>
                    </select>
                      <button onclick="resetMap()" id="resetmap" >RESET MAP</button>

                     <div id="loader"  > Loading...
                            <img alt="loading..." src="images/loading.gif" >
                        </div>
                      <h3 id="thisTrackInfo">&nbsp;</h3>
             
                </div>
                <div id="trackcontainer" class="ui-layout-west">
                      
                      <div id="track_html"></div>
                  </div>
                <div  class="ui-layout-center" >
                    <div id="stepcarouselcontrols" >
                        <p id="unsorted_status">
                            <b>Current Viewing Images:</b> <span id="statusA"></span> to <span id="statusB"></span><b>of:</b> <span id="statusC"></span> <b>near your click point</b>
                        </p>
                        <p id="sorted_status"></p>


                        <div class="trackSort"  ><a href="javascript:sortImagesAlongTrack('left')">Older&nbsp;</a></div>
                        
                        <div id="sliderContainer" >
                            <div id="slider"></div>
                        </div>
                        <div class="trackSort"  ><a href="javascript:sortImagesAlongTrack('right')">&nbsp;Later</a></div>



                        <div id="stepcarouselreorder"></div>

                        <div id="imageInfo" style="display:none" >
                            <p>image name: <font id="this_image_filename"></font></p>
                            <p>image site_code: <font id="this_site_code"></font></p>
                            <p>fk_auv_tracks: <font id="this_fk_auv_tracks"></font></p>
                        </div>

                      <div class="buttons"  >
                          
                          <button  href="#" onclick="sortImagesAlongTrack();return false;" id="sortbytrack" style="display:none" >Sort the Images along the<span> selected</span> track</button>
                      </div>


                    </div>
                  </div>
            </div>

            

        </div>


        

                  <div id="legend" class="jqDnR jqDrag" style="display:none" >
                      <img id="legendClose" alt="Close popup" class="right closeIcon" src="images/close.png" />
                      <h3>Track:</h3>
                      <img src="${server}/geoserver/wms?LAYER=${layernameTrack}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" alt="Legend for ${layernameTrack}" />
                      <h3>Images:</h3>
                      <img id="imagesGetLegendGraphic" src="${server}/geoserver/wms?LAYER=${layernameImages}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" alt="Legend for ${layernameImages}" />
                  </div>

                   <div id="styleSliderContainer" class="jqDnR jqDrag" style="display:none" >
                     <div ><img src="images/close.png" class="right closeIcon" alt="Close popup" onclick="getImageStyle('close')" ></div>
                     <h3>Image Layer Styling options</h3>
                            <div id="styleSlider"></div>
                            <div style="float:left;width:100%">min:<input id=minStyleVal size=2 class="readonly" readonly />
                            max:<input id=maxStyleVal size=2 class="readonly" readonly/></div>
                            <input id="sliderVariable" type="hidden"  />
                         <div class="buttons"  >
                           <button id="styleReloadLink" onclick="getImageStyle()" >SET STYLE</button>
                         </div>
                    </div>



</div>

 <!--/div-->

</body>

</html>
