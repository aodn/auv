<script>

    var wmsServerUrl = '${grailsApplication.config.geoserver.url}/wms';
    var wfsServerUrl = '${grailsApplication.config.geoserver.url}/wfs';

    var layerNamespace = '${grailsApplication.config.geoserver.namespace}';
    var layerNameTracks = '${grailsApplication.config.geoserver.layerNames.tracks}';
    var layerNameImages = '${grailsApplication.config.geoserver.layerNames.images}';
    var fqLayerNameTracks = layerNamespace + ':${grailsApplication.config.geoserver.layerNames.tracks}';
    var fqLayerNameImages = layerNamespace + ':${grailsApplication.config.geoserver.layerNames.images}';

    var map;

    var auvimages; //openlayer layer name
    // pink tile avoidance
    OpenLayers.IMAGE_RELOAD_ATTEMPTS = 5;
    // make OL compute scale according to WMS spec
    OpenLayers.DOTS_PER_INCH = 25.4 / 0.28;

    var test;

    var imagesForTrack = [];
    var availableTracks = [];

    var timeoutID = "";
    var markers = ""; // Openlayers marker layer
    var imageBuffer = 50; // amount of images to retreive either side of current image
    var layersLoading = 0; //

    var currentStyle = "default"; // keep the last style for the images layer

    function mapinit() {
        OpenLayers.ProxyHost = "proxy?url=";

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
            mapOptions: {
                numZoomLevels: 5
            }
        });

        var options = {
            controls: [
                new OpenLayers.Control.PanZoomBar({
                    zoomStopHeight: 5,
                    div: document.getElementById('controlPanZoom')
                }),
                overviewmap,
                new OpenLayers.Control.ScaleLine({
                    div: document.getElementById('mapscale')
                }),
                new OpenLayers.Control.MousePosition({
                    div: document.getElementById('mapcoords'),
                    prefix: '<b>Lon:</b> ',
                    separator: ' <BR><b>Lat:</b> '
                })
            ],
            numZoomLevels: 22,
            projection: "EPSG:4326",
            units: 'degrees'
        };

        map = new OpenLayers.Map('map', options);

        baseLayer = new OpenLayers.Layer.WMS(
                '${grailsApplication.config.baseLayer.name}',
                '${grailsApplication.config.baseLayer.url}',
                {
                    layers: '${grailsApplication.config.baseLayer.name}',
                    styles: '',
                    srs: 'EPSG:4326',
                    format: format,
                    tiled: 'true'
                },
                {
                    isBaseLayer: true,
                    buffer: 1,
                    displayOutsideMaxExtent: true
                }
        );

        auvTracksLayer = new OpenLayers.Layer.WMS(
                fqLayerNameTracks,
                wmsServerUrl,
                {
                    layers: fqLayerNameTracks,
                    styles: '',
                    srs: 'EPSG:4326',
                    format: format,
                    transparent: 'TRUE',
                    tiled: 'true'
                },
                {
                    isBaseLayer: false,
                    transitionEffect: 'resize',
                    buffer: 1,
                    displayOutsideMaxExtent: true
                }
        );

        auvImagesLayer = new OpenLayers.Layer.WMS(
                fqLayerNameImages,
                wmsServerUrl,
                {
                    layers: fqLayerNameImages,
                    styles: '',
                    srs: 'EPSG:4326',
                    format: format,
                    transparent: 'TRUE',
                    tiled: 'true'
                },
                {
                    isBaseLayer: false,
                    transitionEffect: 'resize',
                    buffer: 1,
                    maxResolution: .000035, // important to limit geoserver stress
                    displayOutsideMaxExtent: true
                }
        );

        registerLayer(auvTracksLayer);
        registerLayer(auvImagesLayer);

        markers = new OpenLayers.Layer.Markers("Markers");

        // tracks must obscure auvimages
        map.addLayers([baseLayer, auvImagesLayer, auvTracksLayer, markers]);

        // extra controls
        map.addControl(new OpenLayers.Control.Navigation());

        overviewmap.maximizeControl(true);
        map.setCenter(new OpenLayers.LonLat(135, -26), 3);

        map.events.register("zoomend", map, function () {
            updateUserInfo();
        });

        // create a new event handler for single click query
        clickEventHandler = new OpenLayers.Handler.Click({
            'map': map
        }, {
            'click': function (e) {
                getPointInfo(e);
            }
        });
        clickEventHandler.activate();
        clickEventHandler.fallThrough = false;

        // cursor mods
        map.div.style.cursor = "pointer";
        jQuery("#navtoolbar div.olControlZoomBoxItemInactive ").click(function () {
            map.div.style.cursor = "crosshair";
            clickEventHandler.deactivate();
        });
        jQuery("#navtoolbar div.olControlNavigationItemActive ").click(function () {
            map.div.style.cursor = "pointer";
            clickEventHandler.activate();
        });
    }

    function registerLayer(layer) {
        layer.events.register('loadstart', this, loadStart);
        layer.events.register('loadend', this, loadEnd);
    }

    function loadStart() {
        if (layersLoading == 0) {
            showLoader("true");
        }
        layersLoading++;
    }

    function loadEnd() {
        layersLoading--;
        if (layersLoading == 0) {
            showLoader();
        }
    }

    function updateUserInfo(tailored_msg) {
        var msg = "";
        var trackInfoHeader = jQuery("#trackInfoHeader");
        var currentMsg = trackInfoHeader.html();

        if (tailored_msg != undefined) {
            msg = tailored_msg;
        }
        else {
            if (auvImagesLayer.inRange) {
                msg = "Click on the AUV track to see the nearest images and data links<br/>(Zoom in to get better results)";
                jQuery('#styles').css("visibility", "visible").show("slow");
            }
            else {
                msg = "Zoom in on the AUV icons till their tracks appear, or choose a track from the menu.";
                jQuery('#styles').hide();
            }
        }

        if (msg != currentMsg) {
            trackInfoHeader.html(msg).hide().show('slow');
        }
        trackInfoHeader.show();

    }

    function updateTrackInfo(text) {
        jQuery('#trackInfo').html(text);
    }

    var layer = null;

    function getPointInfo(e) {

        showLoader("true");

        var wmsLayers = map.getLayersByClass("OpenLayers.Layer.WMS");
        for (var key in wmsLayers) {

            layer = map.getLayer(map.layers[key].id);
            var layerName = layer.params.LAYERS;

            var infoFormat = "text/html";

            var params = {
                REQUEST: "GetFeatureInfo",
                EXCEPTIONS: "application/vnd.ogc.se_xml",
                BBOX: layer.getExtent().toBBOX(),
                INFO_FORMAT: infoFormat,
                QUERY_LAYERS: layerName,
                FEATURE_COUNT: (imageBuffer * 2),
                SRS: 'EPSG:4326',
                WIDTH: layer.map.size.w,
                HEIGHT: layer.map.size.h
            };

            if (layer.params.VERSION == "1.1.1") {
                params.X = e.xy.x;
                params.Y = e.xy.y;
            }
            else if (layer.params.VERSION == "1.3.0") {
                params.I = e.xy.x;
                params.J = e.xy.y;
            }

            var url = layer.getFullRequestString(params);

            updateUserInfo('Searching ...');

            if (layerName == fqLayerNameTracks) {
                OpenLayers.loadURL(url, '', this, setTrackHTML, setError);
            }
            else if (layerName == fqLayerNameImages) {

                if (auvImagesLayer.inRange) {
                    OpenLayers.loadURL(url, '', this, setImageHTML, setError);
                }
                else {
                    updateUserInfo();
                    showLoader();
                }
            }
        }
    }

    function setError(e) {
        updateUserInfo('Please try again or zoom in. Nothing found at that click point');
    }

    function resetMap() {

        imagesForTrack = [];
        availableTracks = [];
        setSiteCodeCql();
        map.zoomTo(3);
        map.setCenter(new OpenLayers.LonLat(135, -26), 3);
        markers.clearMarkers();
        jQuery('#trackInfo').html("");
        jQuery('.auvSiteDetails, #sortbytrack').hide();
        toggleGalleryItems(false);
        jQuery('#helpSection').show();
        jQuery('#trackSelector option:first-child').attr("selected", "selected");
        jQuery('#trackSelector')[0].selectedIndex = 0;
        updateTrackInfo("");
        updateUserInfo();
    }

    //find out the min and max values of depth,temperature within the current map boundary
    function setValuesForBBox(bbox, variable) {
        var bb = bbox.split(',');
        bbox = bb[0] + "," + bb[1] + "%20" + bb[2] + "," + bb[3];

        var filter = encodeURIComponent("<ogc:Filter xmlns:ogc=\"http://ogc.org\" xmlns:gml=\"http://www.opengis.net/gml\"><ogc:BBOX>"
                + "<ogc:PropertyName>geom</ogc:PropertyName>"
                + "<gml:Box srsName=\"http://www.opengis.net/gml/srs/epsg.xml\">"
                + "<gml:coordinates>")
                + bbox
                + encodeURIComponent("</gml:coordinates>"
                        + "</gml:Box></ogc:BBOX></ogc:Filter>");

        var url = wmsServer + "/" + wmsServerContext + "/wfs?request=GetFeature&service=WFS&typeName=" + fqLayerNameImages + "&propertyName=" + variable
                + "&filter=" + filter
                + "&version=1.0.0&maxfeatures=1&sortby=" + variable + "+a";


        getXML(url, function (doc) {
            var xmlDoc = doc;
        });
    }

    // return multidimentional array- numbered array of associative arrays
    function getArrayFromXML(xmlDoc, fields_array, parent) {
        var parentCriteria;
        if (parent == fqLayerNameTracks) {
            parentCriteria = {
                "ie": layerNameTracks,
                "schema": layerNamespace,
                "tag": layerNameTracks
            };
        }
        else if (parent == fqLayerNameImages) {
            parentCriteria = {
                "tag": layerNameImages
            };
        }
        else {
            return null;
        }

        var returnArray = [];
        var matchedElements = xmlDoc.getElementsByTagNameNS("*", parentCriteria.tag);

        // Transform each matched element in to an associative array containing key/value pairs for each
        // of its child elements.
        for (var i = 0; i < matchedElements.length; i++) {
            var childKeyValues = [];

            // the xml does not always return the requested element, so the amount of childNodes varies
            for (var y = 0; y < matchedElements[i].childNodes.length; y++) {
                // IE doesn't like empty values
                if (matchedElements[i].childNodes[y].childNodes[0]) {
                    var name = matchedElements[i].childNodes[y].nodeName.replace(layerNamespace + ':', "");
                    var val = matchedElements[i].childNodes[y].childNodes[0].nodeValue;

                    if ( name == "start_track") {
                        val = matchedElements[i].childNodes[y].childNodes[0].childNodes[0].childNodes[0].nodeValue;
                    }
                    childKeyValues[name] = val;
                }
            }
            returnArray[i] = childKeyValues;
        }

        if (returnArray.length > 0) {
            return returnArray;
        }
    }

    var fieldsForTracks = "facility_code,campaign_code,site_code,dive_code_name,dive_report,dive_notes,distance,abstract,platform_code,pattern,kml,metadata_uuid,geospatial_lat_min,geospatial_lon_min,geospatial_lat_max,geospatial_lon_max,geospatial_vertical_min,geospatial_vertical_max,time_coverage_start,time_coverage_end,start_track";

    function populateTracks() {
        // run once to get all tracks into an DOM object
        if (availableTracks.length == 0) {
            var request_string = wfsServerUrl + '?request=GetFeature&service=WFS&typeName=' + fqLayerNameTracks + '&propertyName=' + fieldsForTracks + '&version=1.0.0';

            // get track feature info as XML
            getXML(request_string, populateTracksFromXml);
        }
    }

    function populateTracksFromXml(xmlDoc) {

        var fields_array = fieldsForTracks.split(",");

        var tmp = getArrayFromXML(xmlDoc, fields_array, fqLayerNameTracks);

        if (tmp) {

            for (var i = 0; i < tmp.length; i++) {

                var timeStart = formatISO8601Date(tmp[i]["time_coverage_start"], false);
                var timeEnd = formatISO8601Date(tmp[i]["time_coverage_end"], false);
                var boundsString = tmp[i]["geospatial_lon_min"] + "," + tmp[i]["geospatial_lat_min"] + "," + tmp[i]["geospatial_lon_max"] + "," + tmp[i]["geospatial_lat_max"];
                availableTracks.push({
                    "siteCode": tmp[i]["site_code"],
                    "siteTitle": ucwords(tmp[i]["dive_code_name"]),
                    "campaignCode": tmp[i]["campaign_code"],
                    "boundsString": boundsString,
                    "timeStart": timeStart,
                    "timeEnd": timeEnd,
                    "lonlatString" : tmp[i]["start_track"]
                });
            }

            // populate coresponding drop down box
            availableTracks = sortTrackArray(availableTracks);
            var output = [];
            var campaign = "";

            for (var i = 0; i < availableTracks.length; i++) {

                // write options grouped by campaign code
                var x = availableTracks[i].campaignCode;
                if (campaign != x) {
                    if (i != 0) {
                        // close last option
                        output.push('</optgroup>\n');
                    }
                    output.push('<optgroup label=\"' + x + '\">\n');
                    campaign = x;
                }
                output.push('<option value="' + availableTracks[i].siteCode + '">' + availableTracks[i].siteTitle + '</option>\n');
            }
            output.push('</optgroup>\n');
            jQuery('#trackSelector').append(output.join(''));

        }
        else {
            setError("There is a problem with the WMS server");
        }
    }

    function setTrackHTML(response) {

        var responseText = getTrimBodyContent(response.responseText);

        if (responseText != "") {

            updateTrackInfo(responseText);
            toggleSiteDetails();
            if (!auvImagesLayer.inRange) {
                updateUserInfo("Choose a track below");
            }
            else {
                updateUserInfo();
            }
        }
        else {
            setError();
        }
    }

    // show details if a single site is selected
    function toggleSiteDetails() {
        var allSites = jQuery(".auvSiteDetails");
        if (allSites.length == 1) {
            allSites.css("display", "block")
        }
        else {
            allSites.css("display", "none")
        }
    }

    function getTrimBodyContent(htmlChunk) {
        var ret = "";
        if (htmlChunk.match(/<\/body>/m)) {
            var html_content = htmlChunk.match(/(.|\s)*?<body[^>]*>((.|\s)*?)<\/body>(.|\s)*?/m);
            if (html_content) {
                ret = html_content[2].replace(/^\s+|\s+$/g, '');  // trim
            }
        }
        return ret;
    }

    function setImageHTML(response) {
        var tmp_response = response.responseText;
        var html_content = getTrimBodyContent(tmp_response);

        if (html_content != "") {

            jQuery('#mygallery').html(html_content);

            loadGallery(Math.round(jQuery('#mygallery .panel').size() / 2));
            jQuery('#unsorted_status,  #sortbytrack').show();
            jQuery('#helpSection, #sorted_status').toggle(false);

            toggleGalleryItems(true);
        }
        else {
            updateUserInfo('Please try again or zoom in. Nothing found at that click point');
        }
        showLoader();
    }

    function enableSlider() {
        jQuery("#slider").slider("option", "max", jQuery('#statusC').text());
        jQuery("#slider").slider("option", "value", jQuery('#statusA').text());
        jQuery('#slider').slider("enable");
    }

    function loadGallery(focusImageNumber) {
        stepcarousel.loadcontent('mygallery');
        stepcarousel.moveTo('mygallery', focusImageNumber);
        enableSlider();
    }

    function toggleGalleryItems(show) {
        jQuery('#mygallery, #stepcarouselcontrols').toggle(show);
    }

    function showLoader(vis) {
        jQuery('#loader').css("opacity", 0.8).show();
        if (!(vis == "true" || vis == true)) {
            jQuery('#loader').hide();
        }
    }

    function selectSiteCode(siteCode) {
        jQuery('#trackSelector option[value=' + siteCode + ']').attr("selected", "selected");
        allTracksSelector(siteCode);
    }

    function allTracksSelector(siteCode) {

        var site = availableTracks.filter(function (obj) {
            return obj.siteCode == siteCode;
        })[0];

        toggleGalleryItems(false);

        if (site != undefined) {
            showSiteCode(site);
        }
        else {
            updateTrackInfo("");
        }
    }

    function showSiteCode(site) {

        resetStyleSelect(); // reset the style selector to default
        updateUserInfo();
        updateTrackInfo("");
        setSiteCodeCql(site.siteCode);
        zoomTo(site.lonlatString);
    }

    function setSiteCodeCql(siteCode) {

        var wmsLayers = map.getLayersByClass("OpenLayers.Layer.WMS");
        for (var key in wmsLayers) {
            var layer = map.getLayer(map.layers[key].id);
            var layerName = layer.params.LAYERS;
            if (layerName == fqLayerNameTracks || layerName == fqLayerNameImages) {
                if (siteCode) {
                    layer.mergeNewParams({
                        CQL_FILTER: "site_code like '" + siteCode + "'"
                    });
                }
                else {
                    delete layer.params.CQL_FILTER;
                    layer.redraw();
                }
            }
        }
    }

    function openStyleSlider(param) {
        var minVal = 0;
        var maxVal = 500;
        removeDefaultOption();

        if (param == "default") {
            getImageStyle(param); //set it straight away as there are no options
        }
        else {
            var bbox = map.getExtent().toBBOX();
            if (param == "depth") {
                // get the min and max depth
                var res = setValuesForBBox(bbox, param);
                maxVal = 200;
                jQuery('#styleReloadLink').text("Set Bathymetry Style");
            }

            if (param == "sea_water_temperature") {
                maxVal = 35;
                jQuery('#styleReloadLink').text("Set Temperature Style");
            }

            // create slider to change values for styles pallette
            jQuery('#styleSlider').slider({
                animate: 'normal',
                min: minVal,
                max: maxVal,
                //step: 20,
                values: [minVal, maxVal],
                range: 'min',
                change: function (event, ui) {
                    setStyleSlider();
                    event.stopPropagation();
                },
                slide: function (event, ui) {
                    event.stopPropagation(); //stop jquery drag
                },
                start: function (event, ui) {
                    event.stopPropagation(); //stop jquery drag
                }

            });

            jQuery('#minStyleVal').val(minVal);
            jQuery('#maxStyleVal').val(maxVal);
            jQuery('#styleSliderContainer').show(500);
            jQuery('#sliderVariable').val(param);
        }
    }

    // sets the chosen style for the image layer
    function getImageStyle(style) {

        var extras = "";
        var parameters = "";
        var valMin = jQuery('#styleSlider').slider("values", 0);
        var valMax = jQuery('#styleSlider').slider("values", 1);
        var variable = jQuery('#sliderVariable').val();
        var sld = "";

        // lets us back out of the intended style change
        if (style == "close") {
            // jQuery(".defaultLabel").show(":contains('Image layer Style')");
            jQuery('#styleSliderContainer').hide();
            // change the style selection back to the last values
            jQuery('#imageFormatSelector').val(currentStyle);
        }
        else {

            if (style == "default") {
                // calling the generator script with no parameters gives us a valid but empty sld
                sld = "http://auv.aodn.org.au/AUV/SLDgenerator/auv_images-sld-generator.php?"; // todo fix by moving to groovy controller service
                //jQuery('#styleReloadLink').text("Set Style");
                jQuery('#styleSliderContainer').hide();
                //resetStyleSelect(); // set the style chooser to  default
                currentStyle = style;

            }
            else {
                parameters = "max=" + valMax + "&min=" + valMin + "&variable=" + variable;
                sld = "http://auv.aodn.org.au/AUV/SLDgenerator/auv_images-sld-generator.php?" + parameters;
                // the named layer 'default' must exist in the external sld'
                extras = "&STYLE=default&SLD=" + encodeURIComponent(sld);
            }

            auvimages.mergeNewParams({
                sld: sld
            });

            // set the getlegendGraphic image url
            jQuery('#imagesGetLegendGraphic').attr(
                    "src",
                    wmsServerUrl + '?LAYER=' + fqLayerNameImages + "&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" + extras
            );

            currentStyle = variable;
        }
    }

    function setStyleSlider() {

        var valMin = jQuery('#styleSlider').slider("values", 0);
        var valMax = jQuery('#styleSlider').slider("values", 1);
        if (valMin < valMax) {
            jQuery('#minStyleVal').val(valMin);
            jQuery('#maxStyleVal').val(valMax);
        }
        else {
            alert("min value must be less than max!");
            jQuery('#styleSlider').slider("values", 0, 0);
            jQuery('#styleSlider').slider("values", 1, 200);
            jQuery('#minStyleVal').val(0);
            jQuery('#maxStyleVal').val(200);
        }
    }

    // remove the default option for the image style selector
    function removeDefaultOption() {
        //jQuery(".defaultLabel").hide(":contains('Image layer Style')");
        jQuery(".defaultLabel").hide();
    }

    function resetStyleSelect() {
        // force reset on page load of the style select in Firefox
        var field = jQuery('#imageFormatSelector');
        field.val(jQuery('option:first', field).val());
    }

    function show(css_id) {
        jQuery(css_id).show(450);
    }

    function zoomTo(lonlatString) {
        map.setCenter(new OpenLayers.LonLat.fromString(lonlatString), 18);
    }

    // find a matching val in nested array [cIdx] in imagesForTrack
    function findIndexByCol(val) {

        if (imagesForTrack.length > 0) {

            for (var i = 0; i < imagesForTrack.length; i++) {
                if (imagesForTrack[i]["image_filename"] === val) {
                    //alert(imagesForTrack[i]["image_filename"]+"===="+val);
                    return i;
                }
                //jQuery("#tmp_html").append(imagesForTrack[i]["image_filename"] + " " + val + " <BR>");
            }
        }
        else {
            alert("There are no images for this track");
        }
        return false;

    }

    function getXML(request_string, success_callback) {
        var theurl = encodeURIComponent(request_string);
        var proxyUrl = OpenLayers.ProxyHost + theurl + "&format=xml";

        jQuery.ajax({
            url: proxyUrl,
            success: success_callback
        });
    }

    var windowObjectReference;
    function openPopup(jpgUrl, tiffUrl) {

        var url = ["imagePopup?jpg=", encodeURIComponent(jpgUrl), "&tiff=", encodeURIComponent(tiffUrl)].join("");

        windowObjectReference = window.open(
                url,
                "auv_image",
                "width=650px, height=500px, location=no,scrollbars=yes,resizable=no,directories=no,status=no"
        );

        if (windowObjectReference == null) {
            alert("Unable to open a separate window for image display");
        }
        else {
            windowObjectReference.focus();
        }
    }

    function formatISO8601Date(dateString, localtime) {

        var d_names = new Array("Sun", "Mon", "Tues",
                "Wed", "Thur", "Fri", "Sat");

        var m_names = new Array("Jan", "Feb", "Mar",
                "Apr", "May", "Jun", "Jul", "Aug", "Sep",
                "Oct", "Nov", "Dec");

        var a_p = "";
        var d = new Date();
        if (dateString == undefined) {
            return;
        }
        d.setISO8601(dateString, localtime);

        var curr_date = d.getDate();
        var curr_year = d.getFullYear();
        var curr_month = d.getMonth();
        var curr_day = d.getDay();
        var curr_min = d.getMinutes();
        var curr_sec = d.getMinutes();
        var curr_hour = d.getHours();

        var sup = "";
        if (curr_date == 1 || curr_date == 21 || curr_date == 31) {
            sup = "st";
        }
        else if (curr_date == 2 || curr_date == 22) {
            sup = "nd";
        }
        else if (curr_date == 3 || curr_date == 23) {
            sup = "rd";
        }
        else {
            sup = "th";
        }


        var date = (d_names[curr_day] + " " + curr_date + ""
        + sup + " " + m_names[curr_month] + " " + curr_year);

        if (curr_hour < 12) {
            a_p = "AM";
        }
        else {
            a_p = "PM";
        }
        if (curr_hour == 0) {
            curr_hour = 12;
        }
        if (curr_hour > 12) {
            curr_hour = curr_hour - 12;
        }

        curr_min = curr_min + "";

        if (curr_min.length == 1) {
            curr_min = "0" + curr_min;
        }

        var time = curr_hour + ":" + curr_min + ":" + curr_sec + "" + a_p;
        return (date + " " + time);

    }
    Date.prototype.setISO8601 = function (str, localtime) {
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
    };

    function ucwords(str) {
        // Uppercase the first character of every word in a string
        return (str + '').replace(/^(.)|\s(.)/g, function ($1) {
            return $1.toUpperCase();
        });
    }

    function sortTrackArray(arr) {

        // sort by campaign then labels
        function compare(a, b) {

            var labelA = a.campaignCode + a.siteTitle;
            var labelB = b.campaignCode + b.siteTitle;

            if (labelA < labelB) {
                return -1
            }
            if (labelA > labelB) {
                return 1
            }
            return 0;
        }

        arr.sort(compare);

        return arr;
    }

</script>
