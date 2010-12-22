            var map;
            
            var auvimages; //openlayer layer name
            // pink tile avoidance
            OpenLayers.IMAGE_RELOAD_ATTEMPTS = 5;
            // make OL compute scale according to WMS spec
            OpenLayers.DOTS_PER_INCH = 25.4 / 0.28;

            var test;

            var imagesForTrack = [];
            allTracksHTML = "";

            var timeoutID = "";
            var markers = ""; // Openlayers marker layer
            var imageBuffer = 20; // amount of images to retreive either side of current image



            /*
                pass in: bounding box
                referer: (prod or dev geoserver)


            */ 
     function mapinit(b,mapheight,mapwidth){


                /*if  (this_serverName == 'obsidian.bluenet.utas.edu.au') {  OpenLayers.ProxyHost = "http://obsidian.bluenet.utas.edu.au/webportal/RemoteRequest?url="; }
                if  (this_serverName == 'localhost:8080') { OpenLayers.ProxyHost = "http://localhost/cgi-bin/proxy.cgi?url="; }
                if  (this_serverName == 'localhost') { OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url="; }
                if  (this_serverName == 'preview.emii.org.au') { OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url="; }
                */
               OpenLayers.ProxyHost = "proxy?url="; //grails proxy
               //OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url=";

                if (OpenLayers.ProxyHost == "") {
                    alert("Proxy script is required and not configured. ");
                }

                
                OpenLayers.ImgPath = "theme/dark/";


                // MAP INIT
                format = 'image/png';
                var overviewmap = new OpenLayers.Control.OverviewMap({
                        autoPan: true,
                        maximized: true,
                        minRatio: 4, 
                        maxRatio: 16,
                        mapOptions:{numZoomLevels: 5}
                        });
                
                var bounds = new OpenLayers.Bounds.fromString( b );

                var options = {
                    controls: [
                    new OpenLayers.Control.PanZoomBar({
                            zoomStopHeight: 5,
                            div: document.getElementById('controlPanZoom')
                        }),
                    //new OpenLayers.Control.PanZoomBar,
                    overviewmap,
                    //new OpenLayers.Control.LayerSwitcher(),
                    new OpenLayers.Control.ScaleLine({
                            div: document.getElementById('mapscale')
                        }),
                    new OpenLayers.Control.MousePosition({
                            div: document.getElementById('mapcoords'),
                            prefix: '<b>Lon:</b> ',
                            separator: ' <BR><b>Lat:</b> '
                        })
                    ],
                    //maxExtent: bounds,
                    numZoomLevels: 20,
                    projection: "EPSG:4326",
                    units: 'degrees'
                };
                map = new OpenLayers.Map('map', options);

                
                base = new OpenLayers.Layer.WMS(
                    "simple", server + '/geoserver/wms',
                    {
                        layers: 'topp:aus_coast',
                        styles: '',
                        srs: 'EPSG:4326',
                        format: format,
                        tiled: 'true'
                    },
                    {isBaseLayer: true,
                        buffer: 0,
                        displayOutsideMaxExtent: true
                    }
                );
                auvtracks = new OpenLayers.Layer.WMS(
                    "auv_tracks", server + '/geoserver/wms',
                    {
                        layers: layername_track,
                        styles: '',
                        srs: 'EPSG:4326',
                        format: format,
                        transparent: 'TRUE',
                        tiled: 'true'
                    },
                    {isBaseLayer: false, 
                        transitionEffect: 'resize',
                        buffer: 0,
                        displayOutsideMaxExtent: true
                    }
                );
                auvimages = new OpenLayers.Layer.WMS(
                    "auv_images_vw", server + '/geoserver/wms',
                    {
                        layers: layername_images,
                        styles: '',
                        srs: 'EPSG:4326',
                        format: format,
                        transparent: 'TRUE',
                        tiled: 'true'
                    },
                    {isBaseLayer: false, 
                        transitionEffect: 'resize',
                        buffer: 0,
                        maxResolution: .000035, // important to limit geoserver stress
                        displayOutsideMaxExtent: true
                    }
                );
        
                markers = new OpenLayers.Layer.Markers( "Markers" ); 
    

                // tracks must obscure auvimages
                //map.addLayers([base,auvtracks,markers]);
                map.addLayers([base,auvimages,auvtracks,markers]);
                

                // extra controls
                map.addControl(new OpenLayers.Control.Navigation());
                
                overviewmap.maximizeControl(true);
                
                //map.zoomToMaxExtent();
                map.setCenter(new OpenLayers.LonLat(135,-26), 3)
                

                map.events.register("zoomend", map, function()
                    {
                        updateUserInfo("");
                    });
                // create a new event handler for single click query
                clickEventHandler = new OpenLayers.Handler.Click({
                    'map': map
                }, {
                    'click': function(e) {
                        getpointInfo(e);
                    }
                });
                clickEventHandler.activate();
                clickEventHandler.fallThrough = false;
                
                // cursor mods
                map.div.style.cursor="pointer";
                jQuery("#navtoolbar div.olControlZoomBoxItemInactive ").click(function(){
                    map.div.style.cursor="crosshair";
                    clickEventHandler.deactivate();
                });
                jQuery("#navtoolbar div.olControlNavigationItemActive ").click(function(){
                    map.div.style.cursor="pointer";
                    clickEventHandler.activate();
                });


            }


function updateUserInfo(tailored_msg) {
    var msg ="";

    if (tailored_msg != "") {
            msg = tailored_msg;
    }
    else{
        if (auvimages.inRange){
            msg = "Click on the blue AUV track to see the nearest images";
            jQuery('#styles').css("visibility","visible").show("slow");
        }
        else {
            msg = "Zoom in on the AUV icons till their tracks appear, or choose a track from the menu.";
            jQuery('#styles').hide();
        }
    }
        
   //jQuery("#track_html h3, #thisTrackInfo ").text(msg).show();
   jQuery("#thisTrackInfo").text(msg).show();


}



var layer = null;
function getpointInfo(e) {

    
    
    var lonlat = map.getLonLatFromPixel(e.xy);
    X = Math.round(lonlat.lon * 1000) / 1000;
    Y = Math.round(lonlat.lat * 1000) / 1000;

    var wmsLayers = map.getLayersByClass("OpenLayers.Layer.WMS");

    showLoader("true");

    for (key in wmsLayers) {



        layer = map.getLayer(map.layers[key].id);
        var layerName = layer.params.LAYERS;

        var infoFormat = "text/html";
        
    
        var url = false;
        if (layer.params.VERSION == "1.1.1") {
            url = layer.getFullRequestString({
                REQUEST: "GetFeatureInfo",
                EXCEPTIONS: "application/vnd.ogc.se_xml",
                BBOX: layer.getExtent().toBBOX(),
                X: e.xy.x,
                Y: e.xy.y,
                INFO_FORMAT: infoFormat,
                QUERY_LAYERS: layerName,
                FEATURE_COUNT: (imageBuffer*2),
                BUFFER: layer.getFeatureInfoBuffer,
                SRS: 'EPSG:4326',
                WIDTH: layer.map.size.w,
                HEIGHT: layer.map.size.h
            });
        }
        else if (layer.params.VERSION == "1.3.0") {
            url = layer.getFullRequestString({
                //////////////////////////////////////////////////////////// TO DO change this to getfeature request
                REQUEST: "GetFeatureInfo",
                EXCEPTIONS: "application/vnd.ogc.se_xml",
                BBOX: layer.getExtent().toBBOX(),
                I: e.xy.x,
                J: e.xy.y,
                INFO_FORMAT: 'text/xml',
                QUERY_LAYERS: layerName,
                //Styles: '',
                CRS: 'EPSG:4326',
                BUFFER: layer.getFeatureInfoBuffer,
                WIDTH: layer.map.size.w,
                HEIGHT: layer.map.size.h
            });
        }

        if (url) { 

            updateUserInfo('Searching ...');
            if (layerName == layername_track) {  
                OpenLayers.loadURL(url, '', this, setTrackHTML, setError);
            }
            if (layerName == layername_images) {

                if (auvimages.inRange){
                    OpenLayers.loadURL(url, '', this, setImageHTML, setError);
                }
                else {
                    updateUserInfo("");
                    showLoader("false"); 
                }
            }
            
        } 

    }
}


    function resetMap() {

        map.zoomTo(3);
        map.setCenter(new OpenLayers.LonLat(135,-26), 3)
        markers.clearMarkers();
        jQuery('.auvSiteDetails, #track_html,  #sortbytrack, .trackSort').hide();
        jQuery('#mygallery, #stepcarouselcontrols').toggle(false);
        jQuery('#helpSection').show();
        updateUserInfo("Click on a AUV Icon, or choose from the track list.");
    
    }
    
    // return multidimentional array- numbered array of associative arrays
    function  getArrayFromXML(xmlDoc,fields_array) {

            var myArray = [];
            var tmp = [];
            var x = 0;
             if (xmlDoc.namespaceURI !== null) {
               x = xmlDoc.getElementsByTagName("gml:featureMember");
             //jQuery("#tmp_html").append(x.length + " = <BR>");
             }
             else {
               x = xmlDoc.getElementsByTagNameNS("http://www.opengis.net/gml","featureMember");
             }


             for (i=0; i<x.length; i++) {

                var myArray = [];
                for (y=0; y<fields_array.length; y++) {

                     var z;
                     if (xmlDoc.namespaceURI !== null) {
                        try{ z = xmlDoc.getElementsByTagName("topp:" + fields_array[y])[i].childNodes[0].nodeValue }catch( e ){}
                     }
                     else {
                        try{z = xmlDoc.getElementsByTagNameNS("http://www.openplans.org/topp", fields_array[y] )[i].childNodes[0].nodeValue;}catch( e ){}
                     }
                   // jQuery("#tmp_html").append( z + "<BR>");

                    if (z != "") {
                        myArray[fields_array[y]]= z;

                    }
                }
                tmp[i] = myArray;

            }
            return tmp;
        }

            

    function populateTracks() {
        
        // run once to get all tracks into an object
        if (allTracksHTML == "" ) {
            
            var fields = "facility_code,campaign_code,site_code,dive_report,dive_notes,abstract,platform_code,pattern,kml,metadata_uuid,geospatial_lat_min,geospatial_lon_min,geospatial_lat_max,geospatial_lon_max,geospatial_vertical_min,geospatial_vertical_max,time_coverage_start,time_coverage_end";  
            fields_array = fields.split(",");
            var tmp = []; 
            var trackSelectorValues = [];
            var html_content = "<div class=\"feature\" >\n";

            var request_string =  server + '/geoserver/wfs?request=GetFeature&typeName=' + layername_track + '&propertyName='+ fields + '&version=1.0.0';
            

            // get track feature info as XML   
            
            var xmlDoc = getXML(request_string);
            
            tmp = getArrayFromXML(xmlDoc,fields_array);
           

 
            // now assemble the neccessaries for the simulated getfeatureinfo request
            for (var i=0;i<tmp.length;i++) {

               
                var ids = tmp[i]["site_code"].split("_");
                var site = ucwords(ids[2]);
                //site =tmp[i]["site_code"];
                var dive = ids[3];
                var depth = ids[4];
                var newTitle = site + " - Dive:"+dive+" Depth:"+depth;
                var trackHTML_id = "allTracksHTML_" + i ;
                
                
                var time_coverage_start = formatISO8601Date(tmp[i]["time_coverage_start"],false);
                //var time_coverage_start = tmp[i]["time_coverage_start"];
                var time_coverage_end = formatISO8601Date(tmp[i]["time_coverage_end"],false);
                //var time_coverage_end = tmp[i]["time_coverage_end"];

                html_content = html_content + "<div class=\"featurewhite\" id=\"" + trackHTML_id + "\" >\n";                        
                
                html_content = html_content + "<h4 class=\"getfeatureTitle\">" + newTitle + "</h4>\n";
                html_content = html_content + "<p style=\"display: none;\" class=\"getfeatureCode\">" +tmp[i]["site_code"] + "</p>\n";
                html_content = html_content + "<p style=\"display: none;\" class=\"getfeatureExtent\">" + tmp[i]["geospatial_lon_min"] + "," + tmp[i]["geospatial_lat_min"] + "," + tmp[i]["geospatial_lon_max"] + "," +  tmp[i]["geospatial_lat_max"] + "</p>\n";                                               
                html_content = html_content + "<h5>Start: " + time_coverage_start + "</h5>\n";
                html_content = html_content + "<div style=\"display: none;\" class=\"auvSiteDetails\" id=\"" +tmp[i]["site_code"] + "\">\n";
                
                html_content = html_content + "<!-- hidden for use in AUV page -->\n";                        
                
                html_content = html_content + "<h5>End: " + time_coverage_end + "</h5><br>\n";
                
                
                html_content = html_content + "<table cellspacing=\"0\" cellpadding=\"0\">\n";
                html_content = html_content + "<tbody>";
                html_content = html_content + "<tr><td></td><td>" + tmp[i]["geospatial_lat_max"] + "<b>N</b></td><td></td></tr>\n";
                html_content = html_content + "<tr><td>" + tmp[i]["geospatial_lon_min"] + "<b>W</b></td><td></td><td>" + tmp[i]["geospatial_lon_max"] + "<b>E</b></td></tr>\n";
                html_content = html_content + "<tr><td></td><td>" + tmp[i]["geospatial_lat_min"] + "<b>S</b></td><td></td></tr>\n";
                html_content = html_content + "</tbody></table>\n";
                
                html_content = html_content + "<b>Depth:</b>" + tmp[i]["geospatial_vertical_min"] + "m -&gt;  " + tmp[i]["geospatial_vertical_max"] + "m<br>\n";


                if (tmp[i]["dive_report"] != undefined ) {
                    html_content = html_content + "<a href=\"" + tmp[i]["dive_report"] + "\">Dive Report</a><br>";               
                }
                if (tmp[i]["dive_notes"] != undefined ) {
                    html_content = html_content + "<a href=\"" + tmp[i]["dive_notes"] + "\">Dive Notes</a><br>";               
                }jQuery('#track_html').show();

                jQuery('#track_html h3').hide();

                if (jQuery('#track_html .featurewhite').size() == 1) {
                    jQuery('.featurewhite').addClass('featurewhite_selected');
                    jQuery('.auvSiteDetails').show(1000);
                }

                if (tmp[i]["metadata_uuid"] != undefined ) {
                    html_content = html_content + "<a title=\"http://imosmest.emii.org.au/geonetwork/srv/en/metadata.show?uuid=" + tmp[i]["metadata_uuid"] + "\" class=\"h3\" rel=\"external\" target=\"_blank\" href=\"" + tmp[i]["metadata_uuid"] + "\">Link to the IMOS metadata record</a><br>";                       
                }


                html_content = html_content + "<a alt=\"Download KML\" class=\"h3\" target=\"_blank\" href=\"https://df.arcs.org.au/ARCS/projects/IMOS/public/AUV/WA201004/r20100421_061612_rottnest_04_25m_n_in\" rel=\"external\">Link to data folder</a> <br>\n   <a alt=\"Download KML\" class=\"h3\" target=\"_blank\" href=\"https://df.arcs.org.au/ARCS/projects/IMOS/public/AUV/" +tmp[i]["campaign_code"] + "/" +tmp[i]["site_code"] + "\" rel=\"external\">Download for Google Earth (KML)</a> \n";     
                html_content = html_content + "<BR>\n</div>\n</div>\n</div>\n\n";                
                trackSelectorValues[trackHTML_id] = newTitle;

                
            }


            trackSelectorValues = sortAssoc(trackSelectorValues);
            // populate coresponding drop down box 
            var output = [];                     
            for(key in trackSelectorValues){
                output.push('<option value="'+ key +'">'+ trackSelectorValues[key] +'</option>\n');
            }jQuery('#trackSelector').append(output.join(''));                    
            
            allTracksHTML = html_content;

            
        }
        //populate but keep hidden
        jQuery('#track_html').html(allTracksHTML).hide();
        
        
        
    }

    // reponding to a track picked from the select dropdown
    // all the tracks must be reload into the track_html div
    function allTracksSelector(css_id) {
            populateTracks();
            resetTrackHTML();
            jQuery(css_id + ' .getfeatureTitle').trigger('click');
    }



    function setTrackHTML(response){
        var tmp_response = response.responseText;
        var html_content = "";

        if (tmp_response.match(/<\/body>/m)) {

            html_content  = tmp_response.match(/(.|\s)*?<body[^>]*>((.|\s)*?)<\/body>(.|\s)*?/m);
            if (html_content) {
                //trimmed_content= html_content[2].replace(/(\n|\r|\s)/mg, ''); // replace all whitespace
                html_content  = html_content[2].replace(/^\s+|\s+$/g, '');  // trim
            }
        }
        jQuery('#track_html').html(html_content);

        if (html_content != "") {
            if (!auvimages.inRange){
                updateUserInfo("Choose a track");                
            }
            resetTrackHTML();
            
        }
        else{
            updateUserInfo("No tracks found at your click point.");
        }

        
    }
    
    function resetTrackHTML() {

        //populateTracks(); //cant reset here
        jQuery('#track_html').show();
        jQuery('#track_html h3').hide();

        if (jQuery('#track_html .featurewhite').size() == 1) {
            jQuery('.featurewhite').addClass('featurewhite_selected');
            jQuery('.auvSiteDetails').show(1000);
        }       
       

            
    }

    function setImageHTML(response){

        
        var tmp_response = response.responseText;
        var html_content = "";

        if (tmp_response.match(/<\/body>/m)) {
            
            
            html_content  = tmp_response.match(/(.|\s)*?<body[^>]*>((.|\s)*?)<\/body>(.|\s)*?/m);
            if (html_content) {
                //trimmed_content= html_content[2].replace(/(\n|\r|\s)/mg, ''); // replace all whitespace
                html_content  = html_content[2].replace(/^\s+|\s+$/g, '');  // trim
            }
        }
        
        if (html_content != "") {     

            jQuery('#mygallery').html(html_content);
            jQuery('#mygallery, #stepcarouselcontrols').toggle(true);

            loadGallery(Math.round(jQuery('#mygallery .panel').size()/2));

            jQuery('#unsorted_status,  #sortbytrack').show();
            jQuery('#helpSection, #sorted_status,  .tracksort').hide();
            
            jQuery('#mygallery').css("height","310px"); // sort out why i have to call this
        jQuery('#mygallery, #stepcarouselcontrols').toggle(true);
            
            updateUserInfo("Click an image to view and create public notes about the image");
        }
        else{
            updateUserInfo("No tracks or images found at your click point");
        }
                     

        showLoader("false"); // will be the slowest to load        
       // jQuery.setTemplateLayout('css/map.css?', 'jq');
        
    };

    function setError(response) {
        alert("The server is unavailable");
    }

    function resetSlider() {
        // check if the slider object has been created yet                
        
            jQuery( "#slider" ).slider( "option", "max", jQuery('#statusC').text() ); 
            jQuery( "#slider" ).slider( "option", "value", jQuery('#statusA').text() );
            jQuery('#slider').slider( "enable" );
        
    }


    function sortImagesAlongTrack(reLoad) {

        var answer = confirm("There are many images to sort. This may take a while, OK?")
        if (answer) {
            showLoader("now");
            // disable the slider
            jQuery('#slider').slider( "disable" );
            jQuery('.tracksort, #sortbytrack, #unsorted_status').hide();
            jQuery('#sorted_status').html("<br>").show(); // tmp content to keep spacing

            var fk_auv_tracks = jQuery('#this_fk_auv_tracks').text();
            if (fk_auv_tracks != "") {

                if (!reLoad) {
                    getImageList(fk_auv_tracks);
                }
                // write the HTML
                trackSort(fk_auv_tracks,reLoad);

            }
            else {
                // probably a problem with all the fields or the button was visible when it shouldnt be
                alert("Javascript error: There is no selected image to sort around.");
            }

            showLoader("false");
        }

    }

    function trackSort(fk_auv_tracks,reLoad) {

        if (imagesForTrack.length > 0) {
            
            var min_i= 0;
            var max_i= 0;
            var html_content = "<div class=\"belt\">";
            var image = jQuery('#this_image_filename').text();
            var selected_image = 0;
            var image_idx = findIndexByCol(image);
            
            // move selected image to the left
            if (reLoad == "left") { 

                // calculate left first
                min_i= Math.max( 0, image_idx - (imageBuffer*2 + imageBuffer)); 
                max_i= Math.min(imagesForTrack.length, min_i + imageBuffer*2);
            } 
            // move selected image to the right
            else if (reLoad == "right") { 
                
                // calculate right first
                max_i= Math.min(imagesForTrack.length, image_idx + (imageBuffer*2 + imageBuffer));
                min_i= Math.max(0,max_i - imageBuffer*2); 
                
            } 
            else {
                min_i= Math.max( 0, image_idx -  imageBuffer); 
                max_i= Math.min(imagesForTrack.length, min_i + imageBuffer*2);
            }

            
            
            selected_image = Math.round((max_i- min_i)/2);
            if (min_i== 0) {
                selected_image = 1;
            }
            if (max_i== imagesForTrack.length) {
                selected_image = max_i - min_i;
            }



            var rowcounter = 0;
            var minimum_index = min_i;

            for (;min_i < max_i; min_i++) {


                var ids = imagesForTrack[min_i]["site_code"].split("_");
                var site = ucwords(ids[2]);
                //site = imagesForTrack[min_i]["site_code"]
                var dive = ids[3];
                var depth = ids[4];
                
                // TODO SORT OUT THIS FORMATING
                var time = formatISO8601Date(imagesForTrack[min_i]["time"],false);
                //var time = imagesForTrack[min_i]["time"];

                //datetime = imagesForTrack[min_i][2];                    
                
                html_content = html_content + "<div class=\"panel\"  id=\"auvpanel_" + rowcounter + "\" >";
                html_content = html_content + "<img src=\"http://imos2.ersa.edu.au/AUV/" + imagesForTrack[min_i]["campaign_code"] + "/" + imagesForTrack[min_i]["site_code"] + "/i2jpg/" + imagesForTrack[min_i]["image_filename"] + ".jpg\" />\n";
                html_content = html_content + "<div class=\"panelinfo\">" + site + " - Dive:" + dive + " Depth:" + depth + " " + time + "<br>";
                html_content = html_content +  "Temperature:" + imagesForTrack[min_i]["sea_water_temperature"] + "&deg;c / Salinity:" + imagesForTrack[min_i]["sea_water_salinity"] + " / Chlorophyll:"  + imagesForTrack[min_i]["chlorophyll_concentration_in_sea_water"]+ "</div>\n";
                html_content = html_content + " <div id=\"auvpanelinf_" + rowcounter + "\" style=\"display:none\" >\n";
                html_content = html_content + "   <div class=\"campaign_code\">" + imagesForTrack[min_i]["campaign_code"] + "</div>\n";
                html_content = html_content + "   <div class=\"site_code\">" + imagesForTrack[min_i]["site_code"] + "</div>\n";
                html_content = html_content + "   <div class=\"fk_auv_tracks\">" + fk_auv_tracks + "</div>\n";
                html_content = html_content + "   <div class=\"image_filename\">" + imagesForTrack[min_i]["image_filename"] + "</div>\n";
                html_content = html_content + "   <div class=\"lon\">" + imagesForTrack[min_i]["longitude"] + "</div>\n";
                html_content = html_content + "   <div class=\"lat\">" + imagesForTrack[min_i]["latitude"] + "</div>\n";
                html_content = html_content + " </div>\n";
                html_content = html_content + "</div>\n";
                rowcounter++;
            }
            // end div class=belt
            html_content = html_content + "</div>\n\n";                    

            
            
            var str = "<b>Viewing images for this track:</b> "  + minimum_index+ " to " + max_i+ " of " + imagesForTrack.length;                    
            jQuery('#sorted_status').html(str).show(); 

            jQuery('#mygallery').html(html_content);
            jQuery('#mygallery-paginate, .tracksort').css("visibility","visible").show();
            jQuery('div#mygallery').css("height","310");
            jQuery('#mygallery, #stepcarouselcontrols').toggle(true);
            loadGallery(selected_image);


            
            

        }
        else {
            // probably a problem with all the fields or the button was visible when it shouldnt be
            alert("Javascript error: There was a problem discovering images along this track.");
        }
    }

    function loadGallery(focusImageNumber) {

            stepcarousel.loadcontent('mygallery');
            stepcarousel.moveTo('mygallery',focusImageNumber);
            resetSlider();

    }

    function getImageList(fk_auv_tracks) {  

        imagesForTrack = []; // reset       
        fields = "image_filename,campaign_code,site_code,time,longitude,latitude,sea_water_temperature,sea_water_salinity,chlorophyll_concentration_in_sea_water";  
        fields_array = fields.split(",");

        // get images for track
        if (fk_auv_tracks != "") {
            var xmlDoc = getXML(server + '/geoserver/wfs?request=GetFeature&typeName='+layername_images+'&propertyName='+ fields + '&version=1.0.0&CQL_FILTER=fk_auv_tracks='+ fk_auv_tracks);
            imagesForTrack = getArrayFromXML(xmlDoc,fields_array);
        }
    
    }

    // sets the chosen style
    function setStyle(style){
        
        auvimages.mergeNewParams({
            styles: style
        });
        // set the getlegendGraphic image url
        jQuery('#imagesGetLegendGraphic').attr("src",server + "/geoserver/wms?LAYER=" + layername_images + "&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png&STYLE=" + style);
    }

    function  resetStyleSelect() {
                 // force reset on page load of the style select in Firefox
                var field = jQuery('#imageFormatSelector');
                 field.val(jQuery('option:first', field).val());
    }

    



    function showLoader(vis) {

        // uses jQuery doTimeout
        if (vis == "now") {
            // 
            //jQuery.doTimeout( 'timeoutid', 100, function(){
                jQuery('#loader').css("opacity",0.8).show();
                //jQuery('#loader_thing').text("the loader is on 'now'");
            //});
        }
        else if (vis == "true") {
            // 
            //jQuery.doTimeout( 'timeoutid', 100, function(){
                jQuery('#loader').css("opacity",0.8).show();
                //jQuery('#loader_thing').text("the loader is on 'true'");
            //});
        }
        
        else  {
            //jQuery.doTimeout( 'timeoutid' );
            jQuery('#loader').hide();
            //jQuery('#loader_thing').text("the loader is off");  

        }   
    }

    
    function showHideZoom(css_id,bounds) {

       
        css_id = "#" + css_id;

        jQuery('#track_html').show();
        jQuery('.auvSiteDetails, #track_html .featurewhite').hide();

        if (jQuery(css_id).is(':visible')) {
            jQuery(css_id).hide(50);
            map.zoomTo(3);
            jQuery('.featurewhite').addClass('featurewhite_selected');
        } else {
            jQuery(css_id).show(450);
        
            zoomTo(bounds);
            jQuery('.featurewhite').removeClass('featurewhite_selected')
            jQuery(css_id).parent().addClass('featurewhite_selected');
            jQuery(css_id).parent().show();
            updateUserInfo("Click again on the track, (or zoom further) to see the nearest images");
            //jQuery('#track_html h3,#thisTrackInfo').text(msg).show();
        }            
        

    }
    
    function show(css_id) {
        jQuery(css_id).show(450);
    }
    
    function mergeNewParams(params){
        auvimages.mergeNewParams(params);
        //untiled.mergeNewParams(params);
    }

    function zoomTo(bounds) {                
        map.zoomToExtent(new OpenLayers.Bounds.fromString(bounds));
    }

    

    // find a matching val in nested array [cIdx] in imagesForTrack
    function findIndexByCol(val){

        if (imagesForTrack.length > 0 ) {
            
            for (var i=0; i < imagesForTrack.length; i++) {
                if (imagesForTrack[i]["image_filename"] === val) {
                    //alert(imagesForTrack[i]["image_filename"]+"===="+val);
                    return i;
                }
            }
        }
        else {
            alert("There are no images for this track");
        }
        
        return ctr;
    };

    function getXML(request_string) {

            if (window.XMLHttpRequest)    {
              xhttp=new XMLHttpRequest();
            }
            else  {
              xhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
            var  theurl = URLEncode(request_string);
            xhttp.open("GET",OpenLayers.ProxyHost + theurl,false);
            xhttp.send();
            return xhttp.responseXML;
    }

    function URLEncode (clearString) {
        var output = '';
        var x = 0;
        clearString = clearString.toString();
    
        var regex = /(^[a-zA-Z0-9_.]*)/;
        while (x < clearString.length) {
            var match = regex.exec(clearString.substr(x));
            if (match != null && match.length > 1 && match[1] != '') {
                output += match[1];
                x += match[1].length;
            } else {
                if (clearString[x] == ' ')
                    output += '+';
                else {
                    var charCode = clearString.charCodeAt(x);
                    var hexVal = charCode.toString(16);
                    output += '%' + ( hexVal.length < 2 ? '0' : '' ) + hexVal.toUpperCase();
                }
                x++;
            }
        } 
        return output;
    }

     var windowObjectReference;

    function openPopup(src)   {
        windowObjectReference = window.open("notes?src=" + src , "auv_image", "width=600px, height=600px, location=no,scrollbars=yes,resizable=no,directories=no,status=no");
        if (windowObjectReference == null) {
            alert("Unable to open a seperate window for image annotation");
        }
        else{
            windowObjectReference.focus();
        }

    }


    function formatISO8601Date(dateString,localtime) {
    
        var d_names = new Array("Sun", "Mon", "Tues",
        "Wed", "Thur", "Fri", "Sat");
    
        var m_names = new Array("Jan", "Feb", "Mar",
        "Apr", "May", "Jun", "Jul", "Aug", "Sep",
        "Oct", "Nov", "Dec");
    
        var a_p = "";
        var d = new Date();
        if (dateString == undefined){
            return;
        }
        d.setISO8601(dateString,localtime);
    
        var curr_date = d.getDate();
        var curr_year = d.getFullYear();
        var curr_month = d.getMonth();
        var curr_day = d.getDay();
        var curr_min = d.getMinutes();
        var curr_sec = d.getMinutes();
        var curr_hour = d.getHours();
    
        var sup = "";
        if (curr_date == 1 || curr_date == 21 || curr_date ==31)  {
        sup = "st";
        }
        else if (curr_date == 2 || curr_date == 22)  {
        sup = "nd";
        }
        else if (curr_date == 3 || curr_date == 23)   {
        sup = "rd";
        }
        else   {
        sup = "th";
        }
    
    
        var date = (d_names[curr_day] + " " + curr_date + ""
        + sup + " " + m_names[curr_month] + " " + curr_year);
    
        if (curr_hour < 12)   {
        a_p = "AM";
        }
        else  {
        a_p = "PM";
        }
        if (curr_hour == 0)   {
        curr_hour = 12;
        }
        if (curr_hour > 12)   {
        curr_hour = curr_hour - 12;
        }
    
        curr_min = curr_min + "";
    
        if (curr_min.length == 1)      {
        curr_min = "0" + curr_min;
        }
    
        var time =  curr_hour + ":" + curr_min + ":" + curr_sec + "" + a_p;
        return (date + " " + time);
    
    }
    Date.prototype.setISO8601 = function (str,localtime) {
        var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
        "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
        "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
        var d = str.match(new RegExp(regexp));
    
        var offset = 0;
        var date = new Date(d[1], 0, 1);
    
        if (d[3]) {
            date.setMonth(d[3] - 1);
        }
        if (d[5]) {
            date.setDate(d[5]);
        }
        if (d[7]) {
            date.setHours(d[7]);
        }
        if (d[8]) {
            date.setMinutes(d[8]);
        }
        if (d[10]) {
            date.setSeconds(d[10]);
        }
        if (d[12]) {
            date.setMilliseconds(Number("0." + d[12]) * 1000);
        }
        if (d[14]) {
            offset = (Number(d[16]) * 60) + Number(d[17]);
            offset *= ((d[15] == '-') ? 1 : -1);
        }
        if (localtime) {
            offset -= date.getTimezoneOffset();
        }
        time = (Number(date) + (offset * 60 * 1000));
        this.setTime(Number(time));
    }
    

    function ucwords( str ) {
        // Uppercase the first character of every word in a string
        return (str+'').replace(/^(.)|\s(.)/g, function ( $1 ) {
            return $1.toUpperCase ( );
        } );
    }

    function in_fieldsArray(string, array)  {
        
       for (i = 0; i < array.length; i++)   {          
          if("topp:" + array[i] == string)    {
             return array[i];
          }
       }
    return false;
    }

    // sort associative array keys by value
    function sortAssoc(aInput)
    {
    var aTemp = [];
    for (var sKey in aInput)
    aTemp.push([sKey, aInput[sKey]]);
    aTemp.sort(function () {return arguments[0][1] < arguments[1][1]});
    
    var aOutput = [];
    for (var nIndex = aTemp.length-1; nIndex >=0; nIndex--)
    aOutput[aTemp[nIndex][0]] = aTemp[nIndex][1];
    
    return aOutput;
    }

    /*
    * jqDnR - Minimalistic Drag'n'Resize for jQuery.
    *
    * Copyright (c) 2007 Brice Burgess <bhb@iceburg.net>, http://www.iceburg.net
    * Licensed under the MIT License:
    * http://www.opensource.org/licenses/mit-license.php
    * 
    * $Version: 2007.08.19 +r2
    */
    
    (function($){
    $.fn.jqDrag=function(h){return i(this,h,'d');};
    $.fn.jqResize=function(h){return i(this,h,'r');};
    $.jqDnR={dnr:{},e:0,
    drag:function(v){
    if(M.k == 'd')E.css({left:M.X+v.pageX-M.pX,top:M.Y+v.pageY-M.pY});
    else E.css({width:Math.max(v.pageX-M.pX+M.W,0),height:Math.max(v.pageY-M.pY+M.H,0)});
    return false;},
    stop:function(){E.css('opacity',M.o);$().unbind('mousemove',J.drag).unbind('mouseup',J.stop);}
    };
    var J=$.jqDnR,M=J.dnr,E=J.e,
    i=function(e,h,k){return e.each(function(){h=(h)?$(h,e):e;
    h.bind('mousedown',{e:e,k:k},function(v){var d=v.data,p={};E=d.e;
    // attempt utilization of dimensions plugin to fix IE issues
    if(E.css('position') != 'relative'){try{E.position(p);}catch(e){}}
    M={X:p.left||f('left')||0,Y:p.top||f('top')||0,W:f('width')||E[0].scrollWidth||0,H:f('height')||E[0].scrollHeight||0,pX:v.pageX,pY:v.pageY,k:d.k,o:E.css('opacity')};
    E.css({opacity:0.8});$().mousemove($.jqDnR.drag).mouseup($.jqDnR.stop);
    return false;
    });
    });},
    f=function(k){return parseInt(E.css(k))||false;};
    })(jQuery);

/*
 * jQuery doTimeout: Like setTimeout, but better! - v1.0 - 3/3/2010
 * http://benalman.com/projects/jquery-dotimeout-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
(function($){var a={},c="doTimeout",d=Array.prototype.slice;$[c]=function(){return b.apply(window,[0].concat(d.call(arguments)))};$.fn[c]=function(){var f=d.call(arguments),e=b.apply(this,[c+f[0]].concat(f));return typeof f[0]==="number"||typeof f[1]==="number"?this:e};function b(l){var m=this,h,k={},g=l?$.fn:$,n=arguments,i=4,f=n[1],j=n[2],p=n[3];if(typeof f!=="string"){i--;f=l=0;j=n[1];p=n[2]}if(l){h=m.eq(0);h.data(l,k=h.data(l)||{})}else{if(f){k=a[f]||(a[f]={})}}k.id&&clearTimeout(k.id);delete k.id;function e(){if(l){h.removeData(l)}else{if(f){delete a[f]}}}function o(){k.id=setTimeout(function(){k.fn()},j)}if(p){k.fn=function(q){if(typeof p==="string"){p=g[p]}p.apply(m,d.call(n,i))===true&&!q?o():e()};o()}else{if(k.fn){j===undefined?e():k.fn(j===false);return true}else{e()}}}})(jQuery);
