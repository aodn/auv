<script>

    // *****  TODO get the mapBounds from geoserver
    var buff = 10;
    var mapBounds = "" + (112.947 - buff) + "," + (-33.00 - buff) + "," + (116.46 + buff) + "," + (0.874 + buff);

    var mapheight = '320';
    var mapwidth = '360';
    var size = new OpenLayers.Size(30, 24);
    var offset = new OpenLayers.Pixel(-(size.w / 2) + 5, -(size.h - 1));
    var icon = new OpenLayers.Icon('images/auv-marker.png', size, offset);

    jQuery(document).ready(function () {

        // set map container size before map exists with jQuery
        jQuery("#mapWrapper").height(mapheight).width(mapwidth);


        // highlight for the scale and lonlat info
        function onOver() {
            jQuery("div#mapinfo ").css("opacity", "0.9");
        }

        function onOut() {
            jQuery("div#mapinfo ").css("opacity", "0.5");
        }

        jQuery("div#mapinfo ").css("opacity", "0.5");
        jQuery("div#mapinfo").hover(onOver, onOut);

        // map legend show and hide
        jQuery("#legendToggle").click(function () {
            jQuery('div#legend').toggle();
        });
        jQuery("#legendClose").click(function () {
            jQuery('div#legend').hide();
        });
        jQuery('#legend').jqDrag(); // draggable popup like thingy. Nice


        jQuery('#styleSliderContainer').jqDrag(); // draggable popup like thingy. Nicer


        jQuery('button').mouseover(function () {
            jQuery(this).addClass('hover');
        });
        jQuery('button').hover(function () {
            jQuery(this).addClass('hover');
        }, function () {
            jQuery(this).removeClass('hover');
        });

        // clicking on tracks loaded from sites on map
        jQuery('.getfeatureTitle').live('click', function () {
            selectSiteCode(jQuery(this).siblings('.getfeatureCode').text());
        });

        // slider to change images
        jQuery('#slider').slider({
            animate: 'normal',
            min: 1,
            stop: function (event, ui) {
                var val = jQuery(this).slider("value");

                stepcarousel.moveTo('mygallery', val);
                jQuery('#slider').slider("disable");

            }
        });

        resetStyleSelect(); // reset the style selector to default
        mapinit();

        <g:if test="${flash.zoom}" >
        map.setCenter(new OpenLayers.LonLat(${flash.lon}, ${flash.lat}), 16);
        </g:if>

        // populate the track dropdown select
        populateTracks();

        // then set layout with the map initialised
        jQuery('#mainbody').layout({
            west: {
                minSize: 410,
                spacing_open: 6
            },
            north: {
                size: 120
            }
        });

        jQuery('#galleryControls').layout({
            applyDefaultStyles: true,
            west: {
                minSize: 250
            }
        });

        // hide the gallery
        toggleGalleryItems(false);

        // hide the cover over the ugly load
        jQuery('#loading_cover').fadeOut(1000);

    }); // end jQuery(document).ready(function()

    // timer for jquery slider finction
    var checkTime = 0;
    function keyPressCheck() {
        var currentTime = new Date();
        if ((currentTime.getTime() - checkTime) > 1000) {
            checkTime = currentTime.getTime();
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
        autostep: {enable: false, moveby: 1, pause: 3000},
        panelbehavior: {speed: 4500, stepbyspeed: 400, wraparound: false, wrapbehavior: 'slide', persist: false},
        defaultbuttons: {
            enable: false,
            moveby: 1,
            leftnav: ['images/buttonclose.png', 10, 10],
            rightnav: ['images/buttonopen.png', 10, 10]
        },
        statusvars: ['statusA', 'statusB', 'statusC'], //register 3 variables that contain current panel (start), current panel (last), and total panels
        contenttype: ['inline'], //content setting ['inline'] or ['ajax', 'path_to_external_file']

        onslide: function () {

            var html = "";
            var targetpanel = jQuery('#statusA').text().trim() - 1;
            // set form for ordering images by tracks
            html = jQuery('div#auvpanelinf_' + targetpanel + ' .fk_auv_tracks').text().trim();
            jQuery('#selectedTrackInfo').html(html);
            html = jQuery('div#auvpanelinf_' + targetpanel + ' .site_code').text().trim();
            jQuery('#this_site_code').html(html);
            html = jQuery('div#auvpanelinf_' + targetpanel + ' .site').text().trim();
            jQuery('#sortbytrack span').html("<br>" + ucwords(html));
            html = jQuery('div#auvpanelinf_' + targetpanel + ' .image_filename').text().trim();
            jQuery('#this_image_filename').html(html);

            // highlight the current selected slide (first left)
            jQuery('[id^="auvpanel_"]').css('background-color', 'transparent');
            jQuery('#auvpanel_' + targetpanel).css('background-color', '#3399CC');

            // add/move marker
            var lon = jQuery('div#auvpanelinf_' + targetpanel + ' .lon').text().trim();
            var lat = jQuery('div#auvpanelinf_' + targetpanel + ' .lat').text().trim();
            if (lon != "") {
                var halfIcon = icon.clone();
                markers.clearMarkers();
                markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(lon, lat), halfIcon));

            }
            jQuery('#navButtonL, #navButtonR').show();

            jQuery('#slider').slider("enable");
        }
    });

</script>
