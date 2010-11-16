
/**
 * Instance of OpenLayers map
 */
var map;
var proxy_script="/webportal/RemoteRequest?url=";
//var tmp_response;

var argos = null; // array of existing argo platform_numbers

var popupWidth = 435; //pixels
var popupHeight = 325; //pixels

var requestCount = 0; // getFeatureInfo request count
var queries = new Object(); // current getFeatureInfo requests
var queries_valid_content = false;
var timestamp; // timestamp for getFeatureInfo requests
var X,Y; // getfeatureInfo Click point

var clickEventHandler; // single click handler
var drawinglayer; // OpenLayers.Layer.Vector layer for ncwms transects
var drawingLayerControl; // control wigit for drawinglayer
var toolPanel; // container for OpenLayer controls
var pan; // OpenLayers.Control.Navigation
var zoom; // OpenLayers.Control.ZoomBox

/**
 * Associative array of all current active map layers except
 * for baselayers
 */
var mapLayers = new Object();

/**
 * Associative array of all available base layers
 */
var baseLayers = new Object();

/**
 * Key of the currently selected base layer in baseLayers
 */
var currentBaseLayer = null;


var layersLoading = 0;
var layername; // current layer name

var attempts = 0;
var libraryLoaded = false;
var checkLibraryLoadedTimeout = null;
var libraryCheckIntervalMs=100;
var secondsToWaitForLibrary=30;
var maxAttempts = (secondsToWaitForLibrary * 1000) / libraryCheckIntervalMs;




function inArray (array,value) {
	var i;
	for (i=0; i < array.length; i++) {
		if (array[i] === value) {
			return true;
		}
	}
	return false;
}

function stopCheckingLibraryLoaded() {
    clearInterval(checkLibraryLoadedTimeout);
}

function registerLayer(layer) {
    layer.events.register('loadstart', this, loadStart);
    layer.events.register('loadend', this, loadEnd);
}


function loadStart() {
    if (layersLoading == 0) {
        toggleLoadingImage("block");
    }
    layersLoading++;
}

function loadEnd() {
    layersLoading--;
    if (layersLoading == 0) {
        toggleLoadingImage("none");
    }
}

function toggleLoadingImage(display) {
    var div = document.getElementById("loader");
    if (div != null) {
        if (display == "none") {
            jQuery("#loader").hide(2000);
        }
        else {
            setTimeout(function(){
                if (layersLoading > 0) {
                    div.style.display=display;
                }
            }, 2000);
        }
    }
}

function checkLibraryLoaded() {
    if (typeof OpenLayers == 'undefined') {
        if ((attempts < maxAttempts) && (typeof OpenLayers == 'undefined')) {
            attempts++;
        }
        else if (attempts == maxAttempts) {
            // give up loading - too many attempts
            stopCheckingLibraryLoaded();
            alert(
                "Map not loaded after waiting " + secondsToWaitForLibrary + " seconds.  " +
                "Please wait a moment and then reload the page.  If this does not fix your " +
                "problem, please contact IMOS for assistance"
                );
        }
    }
    else {
        // library loaded OK stop delay timer
        stopCheckingLibraryLoaded();
        libraryLoaded = true;

        parent.updateSafeToLoadMap(libraryLoaded);

        // ok now init the map...
        parent.onIframeMapFullyLoaded();
    }

}

function buildMap() {
    checkLibraryLoadedTimeout = setInterval('checkLibraryLoaded()', libraryCheckIntervalMs);
}

function buildMapReal() {


    var viewportwidth;
    var viewportheight;

    // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight

    if (typeof window.innerWidth != 'undefined')
    {
        viewportwidth = window.innerWidth,
        viewportheight = window.innerHeight
    }

    // IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)

    else if (typeof document.documentElement != 'undefined'
        && typeof document.documentElement.clientWidth !=
        'undefined' && document.documentElement.clientWidth != 0)
        {
        viewportwidth = document.documentElement.clientWidth,
        viewportheight = document.documentElement.clientHeight
    }

    // older versions of IE
    else
    {
        viewportwidth = document.getElementsByTagName('body')[0].clientWidth,
        viewportheight = document.getElementsByTagName('body')[0].clientHeight;
    }
    //alert('<p>Your viewport width is '+viewportwidth+'x'+viewportheight+'</p>');


    // fix IE7 errors due to being in an iframe
    document.getElementById('mapdiv').style.width = '100%';
    document.getElementById('mapdiv').style.height = '100%';

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


    // proxy.cgi script provided by OpenLayers written in Python, must be on the same domain
    OpenLayers.ProxyHost = proxy_script;


    // ---------- map setup --------------- //

    map = new OpenLayers.Map('mapdiv', {
        controls: [
        new OpenLayers.Control.PanZoomBar({
            div: document.getElementById('controlPanZoom')
            }),
        new OpenLayers.Control.LayerSwitcher(),
        new OpenLayers.Control.ScaleLine({
            div: document.getElementById('mapscale')
            }),
        //new OpenLayers.Control.Permalink('Map by IMOS Australia'),
        new OpenLayers.Control.OverviewMap({
            autoPan: true,
            minRectSize: 30,
            mapOptions:{
                resolutions: [  0.3515625, 0.17578125, 0.087890625, 0.0439453125, 0.02197265625, 0.010986328125, 0.0054931640625
                , 0.00274658203125, 0.001373291015625, 0.0006866455078125, 0.00034332275390625,  0.000171661376953125
                ]
                }
            }),
    //new OpenLayers.Control.KeyboardDefaults(),
    new OpenLayers.Control.Attribution(),
        new OpenLayers.Control.MousePosition({
            div: document.getElementById('mapcoords'),
            prefix: '<b>Lon:</b> ',
            separator: ' <BR><b>Lat:</b> '
        })
        ],
        theme: null,
        restrictedExtent: new OpenLayers.Bounds.fromString("-10000,-90,10000,90"),

        //	   These are the resolutions we support: [ 0.3515625, 0.17578125, 0.087890625, 0.0439453125, 0.02197265625, 0.010986328125, 0.0054931640625
        //	     		         , 0.00274658203125, 0.001373291015625, 0.0006866455078125, 0.00034332275390625, 0.000171661376953125
        //	     		         , 8.58306884765625e-05, 4.291534423828125e-05, 2.1457672119140625e-05, 1.0728836059570312e-05, 5.3644180297851562e-06
        //	     		         , 2.6822090148925781e-06, 1.3411045074462891e-06];
        resolutions: [  0.17578125, 0.087890625, 0.0439453125, 0.02197265625, 0.010986328125, 0.0054931640625
        , 0.00274658203125, 0.001373291015625, 0.0006866455078125, 0.00034332275390625,  0.000171661376953125
        ]
    });

    // make OL compute scale according to WMS spec
    OpenLayers.DOTS_PER_INCH = 25.4 / 0.28;
    // Stop the pink tiles appearing on error
    OpenLayers.Util.onImageLoadError = function() {
        this.style.display = "";
        this.src="img/blank.png";
    }

    var container = document.getElementById("navtoolbar");
    pan = new OpenLayers.Control.Navigation({
        id: 'navpan',
        title: 'Pan Control'
    } );
    zoom = new OpenLayers.Control.ZoomBox({
        title: "Zoom and centre [shift + mouse drag]"
    });
    toolPanel = new OpenLayers.Control.Panel({
        defaultControl: pan,
        div: container
    });
    toolPanel.addControls( [ zoom,pan] );
    map.addControl(toolPanel);

    drawinglayer = new OpenLayers.Layer.Vector( "Drawing"); // utilised in 'addLineDrawingLayer'
    drawingLayerControl = new OpenLayers.Control.DrawFeature(drawinglayer, OpenLayers.Handler.Path, {title:'Draw a transect line'});
    toolPanel.addControls( [ drawingLayerControl ] );
    // This will be replaced by ZK call
    //addLineDrawingLayer("ocean_east_aus_temp/temp","http://emii3.its.utas.edu.au/ncWMS/wms");


    // create a new event handler for single click query
    clickEventHandler = new OpenLayers.Handler.Click({
        'map': map
    }, {
        'click': function(e) {
            getpointInfo(e);
            mkpopup(e);
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


    map.events.register("moveend" , map, function (e) {
        parent.setExtent();
        Event.stop(e);
    });

}


// Create a layer on which users can draw transects for single w (i.e. lines on the map)
// handles query
// The supplied layer is queried and the results into the popup
// TODO: zk to call this function add ELEVATION and TIME parameters.
//       set map back to pan control after query
//       Use css to hide unused drawing icon
function addLineDrawingLayer (label,layerName,serverUrl) {
    
    
    drawingLayerControl.activate();
    pan.deactivate();
    zoom.deactivate();

    // the serverUrl may be a relative path to our proxy cache    
    if (serverUrl.substring(0, 1) == "/") {
        // these urls 'will' should have a trailing question mark needing encoding
        if (serverUrl.substring(serverUrl.length - 1, serverUrl.length) == "?") {
            // encode just trailing uqestion mark
             serverUrl = serverUrl.substring(0,serverUrl.length - 1) + "%3F";
        }       
    }
    else {
        serverUrl = serverUrl +"?"
    }
    
    drawinglayer.events.register('featureadded', drawinglayer, function(e) {
        // Destroy previously-added line string
        if (drawinglayer.features.length > 1) {
            drawinglayer.destroyFeatures(drawinglayer.features[0]);
        }
        // Get the linestring specification
        var line = e.feature.geometry.toString();
        // we strip off the "LINESTRING(" and the trailing ")"
        line = line.substring(11, line.length - 1);


        // Load an image of the transect
        var transectUrl =   serverUrl +
            'REQUEST=GetTransect' +
            '&LAYER=' + URLEncode(layerName) +
            '&CRS=' + map.baseLayer.projection.toString() +
            //'&ELEVATION=-5'  +
            //'&TIME=' + isoTValue +
            '&LINESTRING=' + URLEncode(line) +
            '&FORMAT=image/png';

        var inf = new Object();
        inf.transectUrl = transectUrl;
        inf.line = dressUpMyLine(line);
        inf.label = label;
        inf.layerName = layerName;
        mkTransectPopup(inf);

        drawingLayerControl.deactivate();
        
        // place click handler back fudge
        zoom.activate();
        zoom.deactivate(); 
        clickEventHandler.deactivate();
        clickEventHandler.activate();
        pan.activate();
    });
    drawinglayer.events.fallThrough = false;
}

function removeDeselectedLayers(layerIds) {
    for (var key in mapLayers) {
        var found = false;
        var i = 0;
        while (! found && i < layerIds.length) {
            if (key == layerIds[i]) {
                found = true;
            }
            i++;
        }

        if (! found) {
            map.removeLayer(mapLayers[key]);
            mapLayers[key] = null;
        }
    }
}

/*---------------*/

function getpointInfo(e) {

    
    timeSeriesPlotUri = null;
    layername = new Object();
    queries = new Object(); // abandon all old queries
    queries_valid_content = false;
    timestamp = new Date().getTime(); // unique to this click
    requestCount = 0; // reset to keep layer count
    var lonlat = map.getLonLatFromPixel(e.xy);
    X = Math.round(lonlat.lon * 1000) / 1000;
    Y = Math.round(lonlat.lat * 1000) / 1000;

    var wmsLayers = map.getLayersByClass("OpenLayers.Layer.WMS");
    var imageLayers = map.getLayersByClass("OpenLayers.Layer.Image");
    wmsLayers = wmsLayers.concat(imageLayers);
    //alert(Event.findElement(e,Event.elemet));
    

     if (parent.disableDepthServlet == false) {
        getDepth(e);
    }
        


    for (key in wmsLayers) {

        if (map.layers[key] != undefined) {

            var layer = map.getLayer(map.layers[key].id);



            if ((! layer.isBaseLayer) && layer.queryable) {
                var url = false;
                if (layer.animatedNcwmsLayer) {

                   if (layer.tile.bounds.containsLonLat(lonlat)) {
                        url = layer.baseUri +
                        "&EXCEPTIONS=application/vnd.ogc.se_xml" +
                        "&BBOX=" + layer.getExtent().toBBOX() +
                        "&I=" + e.xy.x +
                        "&J=" + e.xy.y +
                        "&INFO_FORMAT=text/xml" +
                        "&CRS=EPSG:4326" +
                        "&WIDTH=" + map.size.w +
                        "&HEIGHT=" +  map.size.h +
                        "&BBOX=" + map.getExtent().toBBOX();

                        timeSeriesPlotUri =
                        layer.timeSeriesPlotUri +
                        "&I=" + e.xy.x +
                        "&J=" + e.xy.y +
                        "&WIDTH=" + layer.map.size.w +
                        "&HEIGHT=" +  layer.map.size.h +
                        "&BBOX=" + map.getExtent().toBBOX();

                    }
                }
                else if (layer.params.VERSION == "1.1.1") {
                    url = layer.getFullRequestString({
                        REQUEST: "GetFeatureInfo",
                        EXCEPTIONS: "application/vnd.ogc.se_xml",
                        BBOX: layer.getExtent().toBBOX(),
                        X: e.xy.x,
                        Y: e.xy.y,
                        INFO_FORMAT: 'text/html',
                        QUERY_LAYERS: layer.params.LAYERS,
                        FEATURE_COUNT: 50,
                        BUFFER: layer.getFeatureInfoBuffer,
                        SRS: 'EPSG:4326',
                        WIDTH: layer.map.size.w,
                        HEIGHT: layer.map.size.h
                    });
                }
                else if (layer.params.VERSION == "1.3.0") {
                    url = layer.getFullRequestString({

                        REQUEST: "GetFeatureInfo",
                        EXCEPTIONS: "application/vnd.ogc.se_xml",
                        BBOX: layer.getExtent().toBBOX(),
                        I: e.xy.x,
                        J: e.xy.y,
                        INFO_FORMAT: 'text/xml',
                        QUERY_LAYERS: layer.params.LAYERS,
                        //Styles: '',
                        CRS: 'EPSG:4326',
                        BUFFER: layer.getFeatureInfoBuffer,
                        WIDTH: layer.map.size.w,
                        HEIGHT: layer.map.size.h
                    });
                }


                if (url) {

                    // append unique ids to each query
                    var uuid = map.layers[key].id + "_" + timestamp;
                    var a;

                    var x =layer.featureInfoResponseType;
                    if (is_ncWms(x)) {

                        layername[layer.name+requestCount] = new Object();
                        a = layername[layer.name+requestCount];
                        a.setHTML_ncWMS = setHTML_ncWMS;
                        a.imageUrl = timeSeriesPlotUri;
                        a.layername = ucwords(layer.name);
                        a.unit = layer.ncWMSMetaData.unit;
                        a.uuid = uuid; // debug
                        a.responseFunction = setHTML_ncWMS;
                        a.url = url;
                        queries[uuid] = a;
                        timeSeriesPlotUri = null;
                    }
                    else if (isWms(x)) {

                        layername[layer.name+requestCount] = new Object();
                        a = layername[layer.name+requestCount];
                        a.layername = ucwords(layer.name);
                        a.uuid = uuid; // debug
                        a.responseFunction = setHTML2;
                        a.url = url;
                        queries[uuid] = a;
                    }

                    requestCount++;


                }
            }
        }
    }


    for (theobj in queries) {
        OpenLayers.loadURL(queries[theobj].url, '', queries[theobj] , queries[theobj].responseFunction, setError);
    }

//setTimeout('hidepopup()', 4000);
}

function handleQueryStatus(theobj) {

    var c = "";
    var cnt = 0;
    var inaarray = false;
    var title;
    var body;

    // check its in the current click query
    for (x in queries) {
        if (queries[x].uuid == theobj.uuid) {
            inaarray = true;
        }
    }

    if (inaarray) {

        delete queries[theobj.uuid];

        for (k in queries) {
            cnt++;
        }


        if (requestCount != 1 ){
            c="s";
        } else{
            c=" ";
        }

        if (cnt > 0) {

            if (requestCount != 1 ){
                c="s";
            } else{
                c=" ";
            }
            title = "<h4>Searching <b>" + requestCount + "</b> layer" + c + "</h4>";
            if (cnt != 1 ){
                c="s";
            } else{
                c=" ";
            }
            body = "Waiting on the response for <b>" +
            cnt + "</b> layer" + c +
            "<img src=\"/img/loading_small.gif\" />";

        }
        else {

            var tics = new Date().getTime(); // unique to this click
            tics =  tics - timestamp;
            var d = new Date(parseInt(tics));
            var milli = Math.round(60 * (d.getMilliseconds()/1000));

            tics =  "<b>" + d.getSeconds() + ":" + milli + "</b> seconds" ;

            if (queries_valid_content) {
                title = "<h4>Layer Search Finished</h4>";
            }
            else {                
                title = "<h4>No layer information found</h4>";
            }
            
            body = "<small>" + requestCount + " layer" + c + " responded in " + tics + "</small>";

        }
        // try to get the general information
        // setDepth will try to set 'featureinfoGeneral' as well
         if (parent.disableDepthServlet == false) {
            body = "<div id=\"featureinfoGeneral\">" + jQuery('#featureinfodepth').html() + "</div>" + body;
        }
        else {
            body = "<div id=\"featureinfoGeneral\">&nbsp;</div>" + body;
        }
        
            
        jQuery('#featureinfoheader').html(title).fadeIn(1200);
        jQuery('#featureinfostatus').html(body).fadeIn(400);
        return true;
    }
    else {
        return false;
    }

}

function is_ncWms(type) {
    return ((type == parent.ncwms)||
        (type == parent.thredds));
}

function isWms(type) {
    return (
        (type == parent.wms100) ||
        (type == parent.wms110) ||
        (type == parent.wms111) ||
        (type == parent.wms130) ||
        (type == parent.ncwms) ||
        (type == parent.thredds));
}


function getDepth(e) {

    var I= e.xy.x; //pixel on map
    var J= e.xy.y; // pixel on map
    var click = map.getLonLatFromPixel(new OpenLayers.Pixel(I,J));

    var url = "DepthServlet?" +
            "lon=" + click.lon +
            "&lat="  + click.lat ;
    
    var request = OpenLayers.Request.GET({
        url: url,
        headers: {
            "Content-Type": "application/xml"
        },
        callback: setDepth
    });
}

function setDepth(response) {

    var i = 0;
    var total_depths = 0;
    var xmldoc = response.responseXML;
    var depth = parseFloat(xmldoc.getElementsByTagName('depth')[0].firstChild.nodeValue);
    var desc = (depth > 0) ? "Altitude " : "Depth ";  
    var str = desc + "<b>" + Math.abs(depth) + "m</b>" ;

    str = str + " Lon:<b> " + X + "</b> Lat:<b> " + Y + "</b>";
    jQuery('#featureinfodepth').html(str);
    
    // if this id is available populate it and hide featureinfodepth
    if (jQuery('#featureinfoGeneral')) {
      jQuery('#featureinfoGeneral').html(str).fadeIn(400);
      jQuery('#featureinfodepth').hide();
    }
    

}

// designed for Geoserver valid response
function setHTML2(response) {

        var pointInfo_str = '';

        var tmp_response = response.responseText;
        var html_content = "";

        if (tmp_response.match(/<\/body>/m)) {

            html_content  = tmp_response.match(/(.|\s)*?<body[^>]*>((.|\s)*?)<\/body>(.|\s)*?/m);
            if (html_content) {
                //trimmed_content= html_content[2].replace(/(\n|\r|\s)/mg, ''); // replace all whitespace
                html_content  = html_content[2].replace(/^\s+|\s+$/g, '');  // trim
            }
        }

        if (html_content.length > 0) {
            // at least one valid query
            queries_valid_content = true;
            this.layer_data = true;
        }
        
    if (handleQueryStatus(this)) {
        setFeatureInfo(html_content,true);
    }
    

}

function setHTML_ncWMS(response) {

    var xmldoc = response.responseXML;
    var lon  = parseFloat(xmldoc.getElementsByTagName('longitude')[0].firstChild.nodeValue);
    var lat  = parseFloat(xmldoc.getElementsByTagName('latitude')[0].firstChild.nodeValue);
    var startval  = parseFloat(xmldoc.getElementsByTagName('value')[0].firstChild.nodeValue);
    var x    = xmldoc.getElementsByTagName('value');
    var vals = "";
    var time = xmldoc.getElementsByTagName('time')[0].firstChild.nodeValue;

    if (x.length > 1) {
        var endval = parseFloat(xmldoc.getElementsByTagName('value')[x.length -1].childNodes[0].nodeValue);
        var endtime = xmldoc.getElementsByTagName('time')[x.length -1].firstChild.nodeValue;
    }

    var html = "";
    var  extras = "";
    
    if (lon) {  // We have a successful result

        if (!isNaN(startval) ) {  // may have no data at this point
            var layer_type = " - ncWMS Layer";

            var human_time = new Date();
            human_time.setISO8601(time);

            // ncwms timeseries plot image
            if (this.imageUrl != null) {
                extras =
                "<image height=\"300\"width=\"325\"class=\"spaced\" src='" + this.imageUrl + "' " +
                "title='time series plot for "+this.layername+"' " +
                "alt='time series plot "+this.layername+"' />";
                layer_type = " - ncWMS Animated Layer";
                //alert(this.imageUrl);
            }
            
            var old_startval = startval + this.unit;
            var startval =getCelsius(startval, this.unit);
           

            if (endval == null) {
                vals = "<br /><b>Value at </b>"+human_time.toUTCString()+"<b> " + startval[0] +"</b>"+ startval[1] + startval[2];
            }
            else {

                var human_endtime = new Date();
                human_endtime.setISO8601(endtime);
                var endval =getCelsius(endval, this.unit);

                vals = "<br /><b>Start date:</b>"+human_time.toUTCString()+": <b>" + startval[0] +"</b>"+ startval[1] + startval[2];
                vals += "<br /><b>End date:</b>"+human_endtime.toUTCString()+":<b> " + endval[0] +"</b>"+ endval[1]  + endval[2];
                vals += "<BR />";
            }

            lon = toNSigFigs(lon, 7);
            lat = toNSigFigs(lat, 7);

            layer_type = this.layername + layer_type;


            html = "<h3>"+layer_type+"</h3><div class=\"feature\"><b>Lon:</b> " + lon + "<br /><b>Lat:</b> " + lat +
            vals + "\n<BR />" + extras;

                // to do add transect drawing here
                //
           html = html +"<BR><h6>Get a graph of the data along a transect via layer options!</h6>\n";
           // html = html +" <div  ><a href="#" onclick=\"addLineDrawingLayer('ocean_east_aus_temp/temp','http://emii3.its.utas.edu.au/ncWMS/wms')\" >Turn on transect graphing for this layer </a></div>";

            html = html +"</div>" ;
        }

    }
    else {
        html = "Can't get feature info data for this layer <a href='javascript:popUp('whynot.html', 200, 200)'>(why not?)</a>";
    }

    setFeatureInfo(html,true);
    queries_valid_content = true;
    handleQueryStatus(this);
	



}

// if units label is known as fahrenheit or kelvin, convert val to celcius
function getCelsius(val,src_units) {
     var cel = "";
     var c = "&#176;C";
     var ret = [];
     var old = "";
     src_units = src_units.toLowerCase();
     src_units = src_units.replace(/^\s+|\s+$/g, '');  // trim
     // arrays hold all posiible names for farenheight or kelvin and celcius
     var celNameArray = ["c","celcius","cel","deg_c"];
     var farNameArray = ["f","fahrenheit"];
     var kelNameArray = ["k","kelvin","kel"]
     
     
     // fahrenheit
      if (inArray(farNameArray,src_units)) {
        cel = (val - 32) / 1.8;
        old = " (<b>"+toNSigFigs(val,4) +"</b>fahrenheit)";
        ret = [toNSigFigs(cel,4),c,old];
      }
      // kelvin
      else if (inArray(kelNameArray,src_units)) {
        cel = val - 272.15;
        old = " (<b>" + toNSigFigs(val,4) + "</b>kelvin)";
        ret = [toNSigFigs(cel,4),c,old];
      }
      // celcius
      else if (inArray(celNameArray,src_units)) {
         ret = [toNSigFigs(val,4),c,""];
         cel = "himum";
      }

      
      // if cel empty then the unit wasnt temperature
      // or we cant even anticipate..
      if (cel == "") {
          cel = val;
          return [toNSigFigs(cel,4),src_units,""];
      }
      else {
          return ret;
      }

}

function getCurrentFeatureInfo() {
    return jQuery('#featureinfocontent').html();
}

function setFeatureInfo(content,line_break) {

    showpopup();
    var br = "";
    if (line_break == true ) {
        br = "<hr>\n\n";
    }
    //jQuery('#featureinfocontent').html(content).hide();
    if (content.length > 0 ) {
        jQuery('#featureinfocontent').prepend(content+br).hide().fadeIn(400);
    }
    if (jQuery('#featureinfocontent').html() != "") {
        map.popup.setSize(new OpenLayers.Size(popupWidth,popupHeight));
        //
    }

    jQuery('#featureinfocontent').fadeIn(400);

}

// Special popup for ncwms transects
function mkTransectPopup(inf) {

    killTransectPopup(); // kill previous unless we can make these popups draggable
    var posi = map.getLonLatFromViewPortPx(new OpenLayers.Geometry.Point(60,20));

    var html = "<div id=\"transectImageheader\">" +
                "</div>" +
                "<div id=\"transectinfostatus\">" +
                "<h3>" + inf.label + "</h3><h5>Data along the transect: </h5>" + inf.line +  "</div>" +
                "<BR><img src=\"" + inf.transectUrl + "\" />" +
                "</div>" ;    

    popup2 = new OpenLayers.Popup.AnchoredBubble( "transectfeaturepopup",
        posi,
        new OpenLayers.Size(popupWidth,60), 
        html,
        null, true, null);

    popup2.autoSize = true;
    map.popup2 = popup2;
    map.addPopup(popup2);

    
}

function killTransectPopup() {
    if (map.popup2 != null) {
        map.removePopup(map.popup2);
        map.popup2.destroy();
        map.popup2 = null;
    }
}

// called when a click is made
function mkpopup(e) {
    
    var point = e.xy;
    var pointclick = map.getLonLatFromViewPortPx(point.add(2,0));

    // kill previous popup to startover at new location
    if (map.popup != null) {
        map.removePopup(map.popup);
        map.popup.destroy();
        map.popup = null;
    }

    var html = "<div id=\"featureinfoheader\"><h4>New Query:</h4></div>" +
    "<div id=\"featureinfostatus\">" +
    "Waiting on the response for <b>" + requestCount + "</b> layers..." +
    "<img class=\"small_loader\" src=\"/img/loading_small.gif\" /></div>"  +
    "<div id=\"featureinfodepth\"></div>" +
    "<div class=\"spacer\" style=\"clear:both;height:2px;\">&nbsp;</div>" +
    "<div id=\"featureinfocontent_topborder\"><img id=\"featureinfocontent_topborderimg\" src=\"img/mapshadow.png\" />\n" +
    "<div id=\"featureinfocontent\"></div>\n</div>" ;
    popup = new OpenLayers.Popup.AnchoredBubble( "getfeaturepopup",
        pointclick,
        new OpenLayers.Size(popupWidth,popupHeight), 
        html,
        null, true, null);


    popup.panMapIfOutOfView = true; 
    //popup.autoSize = true;
    map.popup = popup;
    map.addPopup(popup);
    map.popup.setOpacity(0.9);

    /* shrink back down while searching.
     * popup will always pan into view with previous size.
     * close image always therefore visible
    */
    map.popup.setSize(new OpenLayers.Size(popupWidth,60));

    // a prompt for stupid people
    if (requestCount == "0") {
        jQuery('#featureinfostatus').html("<font class=\"error\">Please choose a queryable layer from the menu..</font>").fadeIn(400);
    }
}

function hidepopup() {
    if ((map.popup != null)) {
         jQuery('div.olPopup').fadeOut(900);
    }
}

function showpopup() {

    if ((map.popup != null)) {
        map.popup.setOpacity(1);
        setTimeout('imgSizer()', 900); // ensure the popup is ready
    }

}

//server might be down
function setError(response) {
    alert("The server is unavailable");
}

Date.prototype.setISO8601 = function (string) {
    var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
    "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
    "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    var d = string.match(new RegExp(regexp));

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

    offset -= date.getTimezoneOffset();
    time = (Number(date) + (offset * 60 * 1000));
    this.setTime(Number(time));
}

//Formats the given value to numSigFigs significant figures
//WARNING: Javascript 1.5 only!
function toNSigFigs(value, numSigFigs) {
    if (!value.toPrecision) {
        return value;
    } else {
        return value.toPrecision(numSigFigs);
    }
}

function ucwords( str ) {
    // Uppercase the first character of every word in a string
    return (str+'').replace(/^(.)|\s(.)/g, function ( $1 ) {
        return $1.toUpperCase ( );
    } );
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

function imgSizer(){
    //Configuration Options
    var max_width = popupWidth -70 ; 	//Sets the max width, in pixels, for every image
    var selector = 'div#featureinfocontent .feature img';

    //destroy_imagePopup(); // make sure there is no other
    var tics = new Date().getTime();

    $(selector).each(function(){
        var width = $(this).width();
        var height = $(this).height();
        //alert("here");
        if (width > max_width) {

            //Set variables for manipulation
            var ratio = (max_width / width );
            var new_width = max_width;
            var new_height = (height * ratio);
            //alert("(popupwidth "+max_width+" "+width + ") " +height+" * "+ratio);

            //Shrink the image and add link to full-sized image
            $(this).animate({
                width: new_width
            }, 'slow').width(new_height);
               
            $(this).hover(function(){
                $(this).attr("title", "This image has been scaled down.")
            //$(this).css("cursor","pointer");
            });

        } //ends if statement
    }); //ends each function


}

function destroy_imagePopup(imagePopup) {
    jQuery("#" + imagePopup ).hide();
}


/*jQuery showhide (toggle visibility of element)
 *  param: the dom element
 *  ie: #theId or .theClass
 */
function showhide(css_id) {
      $(css_id).toggle(450);
}
/*jQuery show 
 *  param: the dom element
 *  ie: #theId or .theClass
 */
function show(css_id) {
      $(css_id).show(450);
}




function dressUpMyLine(line){

    var x = line.split(",");
    var newString = "";

    for(i = 0; i < x.length; i++){
            var latlon = x[i].split(" ");
            var lon = latlon[0].substring(0, latlon[0].lastIndexOf(".") + 4);
            var lat = latlon[1].substring(0, latlon[1].lastIndexOf(".") + 4);
            newString = newString + "Lon:" + lon + " Lat:" +lat + ",<BR>";
    }
    return newString;
}

function centreOnArgo(base_url, argo_id, zoomlevel) {

    getArgoList(base_url);

    if (IsInt(argo_id)) {

        var xmlDoc = getXML(base_url + '/geoserver/wfs?request=GetFeature&typeName=topp:argo_float&propertyName=last_lat,last_long&version=1.0.0&CQL_FILTER=platform_number='+ argo_id + '&MAXFEATURES=1');
        var x= xmlDoc.getElementsByTagName('topp:argo_float');

        if (x.length > 0) {

            var lat = xmlDoc.getElementsByTagName("topp:last_lat")[0].childNodes[0].nodeValue;
            var lon = xmlDoc.getElementsByTagName("topp:last_long")[0].childNodes[0].nodeValue;

            //map.setCenter(new OpenLayers.LonLat(lon,lat),zoomlevel,1,1);

            // no zooming in
            map.setCenter(new OpenLayers.LonLat(lon,lat),zoomlevel,1,1);
            hidepopup(); // clear the popup out of users face
        }
          
    }
    else {
        alert("Please enter an Argo ID number");
    }

}

// This function gets over the Firefox 4096 character limit for XML nodes using 'textContent''
// IE doesn’t support the textContent attribute
function getNodeText(xmlNode)
{
    if(!xmlNode) return '';
    if(typeof(xmlNode.textContent) != "undefined") return xmlNode.textContent;
    return xmlNode.firstChild.nodeValue;
}

function doSOSLinks() {

    depth = '90'
    phenom = 'temperature';
    var x  = Array();

    show('#sos');
    query = 'http://test.emii.org.au/deegree-sos/services?request=GetObservation&service=SOS&version=1.0.0&offering=ID_nrsmai_';
    query = query + depth;
    query = query + 'm_depth&observedproperty=urn:ogc:def:phenomenon:OGC:';
    query = query + phenom;
    query = query + '&responseformat=text/xml;subtype=%22om/1.0.0%22';
    res =  Array();
    var xmlDoc = getXML(query);
    //x= xmlDoc.getElementsByTagName('swe:values')[0].childNodes[0].nodeValue.split("@@");
    x= getNodeText(xmlDoc.getElementsByTagName('swe:values')[0]);

    x = x.replace(/@/g,'');

    if (x.length > 0) {
        newHTML = '<p>' + query + '</p><table class="featureInfo" ><tr><th>Date/Time</th><th>' + phenom + ' at ' + depth + 'm</th></tr>';
         lines = x.split("\n");
         //alert(lines.length + ' ' + lines[lines.length])
         for (i=lines.length-11; i<lines.length-1; i++)   {
                     
             vals = lines[i].split(",");
            newHTML =  newHTML + '<tr><td>'+vals[0]+'</td><td>'+vals[1]+'</td></tr>';
        }
        newHTML = newHTML + '</table>';
        jQuery('#sos1').html(newHTML);
    }

    


}



/*
* Opens the form area
* Populates argos[]
*/
function getArgo(base_url,inputId) {


    show('#argo_find');
    getArgoList(base_url);

    // turn on auto complete
    if (argos.length > 0) {
        $("input#" + inputId).autocomplete(argos);
    }

}

function isArgoExisting (base_url,argo_id) {

     var status = false;

     if (!IsInt(argo_id)) {
        alert("Please enter an Argo ID number");        
    }    
    else {
        
            getArgoList(base_url) ;

            if(argos.length > 0) {
                if ( inArray(argos,argo_id))  {
                    status = true;
                 }
                 //
                else {
                    alert("Your supplied Argo ID number is not known in this region");
                }
            }
            else {
                // gracefully forget about it if the list of argos failed
                status = true;
            }

    }
    return status;
}

// called via argo getfeatureinfo results
function drawSingleArgo(base_url, argo_id, zoomlevel) {
     
    if (isArgoExisting(base_url,argo_id)) {

        parent.setExtWmsLayer(base_url +'/geoserver/wms','Argo - ' + argo_id + '','1.1.1','argo_float','','platform_number = '+ argo_id + '','argo_large');
        centreOnArgo(base_url, argo_id, null);
    }

    
}

function getArgoList(base_url) {
    

        if (argos == null) {
            argos =  Array();
            var xmlDoc = getXML(base_url + '/geoserver/wfs?request=GetFeature&typeName=topp:argo_float&propertyName=platform_number&version=1.0.0');
            var x= xmlDoc.getElementsByTagName('topp:argo_float');

            if (x.length > 0) {
                 for (i=0;i<x.length;i++) {
                    argos[i]= x[i].getElementsByTagName("topp:platform_number")[0].childNodes[0].nodeValue;
                 }
            }

            else {
                // tried once and failed leave it alone
                argos =  Array();
            }

        }
    
}


function IsInt(sText) {

   var ValidChars = "0123456789";
   var IsInt= true;
   sText = sText.trim();
   var Char;
   if (sText.length == "0") {
         IsInt = false;
   }
   else {
       for (i = 0; i < sText.length && IsInt == true; i++) {
          Char = sText.charAt(i);
          if (ValidChars.indexOf(Char) == -1) {
             IsInt = false;
          }
       }
   }   
   return IsInt;

}



function getXML(request_string) {

        if (window.XMLHttpRequest)  {
            xhttp=new XMLHttpRequest();
        }
        else {// Internet Explorer 5/6
            xhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }     
        request_string=request_string.replace(/\\/g,'');
        var  theurl = URLEncode(request_string);        
        xhttp.open("GET","RemoteRequest?url=" + theurl,false);
        xhttp.send("");
       return xhttp.responseXML;

}


function acornHistory(request_string,div,data) {

        var xmlDoc = getXML(request_string);
        var x=xmlDoc.getElementsByTagName(data);
        str= "";
       
        if (x.length > 0) {
            str = str + ("<table class=\"featureInfo\">");
            str =str + ("<tr><th>Date/Time</th><th>Speed</th><th>Direction</th></tr>");
            for (i=0;i<x.length;i++)
                {
                str = str + ("<tr><td>");
                var dateTime =  (x[i].getElementsByTagName("topp:timecreated")[0].childNodes[0].nodeValue);
                str = str + formatISO8601Date(dateTime);
                str = str + ("</td><td>");
                str = str + (x[i].getElementsByTagName("topp:speed")[0].childNodes[0].nodeValue) + "m/s";
                str = str + ("</td><td>");
                str = str + (x[i].getElementsByTagName("topp:direction")[0].childNodes[0].nodeValue) + "&#176;N";
                str = str + ("</td></tr>");
            }
            str = str + ("</table>");
        }
        else {
            str="<p class=\"error\">No previous results.</p>";
        }
        jQuery("#acorn"+div).html(str);     
        jQuery("#acorn"+div).show(500);
        jQuery("#acorn"+div + "_single").hide();   


    return false;
}



function formatISO8601Date(dateString) {

    var d_names = new Array("Sun", "Mon", "Tues",
    "Wed", "Thur", "Fri", "Sat");

    var m_names = new Array("Jan", "Feb", "Mar",
    "Apr", "May", "Jun", "Jul", "Aug", "Sep",
    "Oct", "Nov", "Dec");

    var a_p = "";
    var d = new Date();
	d.setISO8601(dateString);

    var curr_date = d.getDate();
    var curr_year = d.getFullYear();
    var curr_month = d.getMonth();
    var curr_day = d.getDay();
    var curr_min = d.getMinutes();
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

    var time =  curr_hour + ":" + curr_min + "" + a_p;
    return (date + " " + time);

}
// Not handling timezone offset correctly
Date.prototype.setISO8601 = function (string) {
    var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
        "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
        "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    var d = string.match(new RegExp(regexp));

    var offset = 0;
    var date = new Date(d[1], 0, 1);

    if (d[3]) {date.setMonth(d[3] - 1);}
    if (d[5]) {date.setDate(d[5]);}
    if (d[7]) {date.setHours(d[7]);}
    if (d[8]) {date.setMinutes(d[8]);}
    if (d[10]) {date.setSeconds(d[10]);}


    //if (d[12]) {date.setMilliseconds(Number("0." + d[12]) * 1000);}
    //if (d[14]) {
    //    offset = (Number(d[16]) * 60) + Number(d[17]);
    //    offset *= ((d[15] == '-') ? 1 : -1);
    //}

    //offset -= date.getTimezoneOffset();
    time = (Number(date) + (offset * 60 * 1000));
    this.setTime(Number(time));
}
