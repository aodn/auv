<!--*************************************************
  Copyright 2010 IMOS
  The IMOS AUV Viewer is distributed under
  the terms of the GNU General Public License
*************************************************-->


<html>
<head>
    <title>IMOS AUV Images Viewer</title>
    <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'map.css')}"/>
    <link rel="stylesheet" type="text/css" href="${resource(dir: 'css', file: 'overcast/jquery-ui-1.8.5.custom.css')}"/>

    <meta name="layout" content="main"/>

    <script type="text/javascript" src="${resource(dir: 'js', file: 'OpenLayers-2.9.js')}"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery-1.4.2.min.js')}"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.layout1.3.0.js')}"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jqDnR.js')}"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery-ui-1.8.5.custom.min.js')}"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'stepcarousel.js')}"></script>

    <link rel="shortcut icon" href="${resource(dir: 'images', file: 'favicon.ico')}" type="image/x-icon"/>
    <link href='http://fonts.googleapis.com/css?family=Lobster' rel='stylesheet' type='text/css'>

    <g:render template="auv_functions_js"></g:render>
    <g:render template="finder_js"></g:render>

</head>

<body>

<div id="loading_cover"></div>

<div id="selectedTrackInfo" style="display:none"></div>

<div id="legend" class="jqDnR jqDrag" style="display:none">

    <img id="legendClose" alt="Close popup" class="right closeIcon" src="images/close.png"/>

    <h3>Track:</h3>
    <img src="${geoserver.url}/wms?LAYER=${geoserver.layerNames.tracks}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png"
         alt="Legend for ${geoserver.layerNames.tracks}"/>

    <h3>Images:</h3>
    <img id="imagesGetLegendGraphic"
         src="${geoserver.url}/wms?LAYER=${geoserver.layerNames.tracks}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png"
         alt="Legend for ${geoserver.layerNames.images}"/>
</div>

<div id="styleSliderContainer" class="jqDnR jqDrag" style="display:none">
    <div><img src="images/close.png" class="right closeIcon" alt="Close popup" onclick="getImageStyle('close')"></div>

    <h3>Image Layer Styling options</h3>

    <div id="styleSlider"></div>

    <div style="float:left;width:100%">min:<input id="minStyleVal" size=2 class="readonly" readonly/>
        max:<input id="maxStyleVal" size=2 class="readonly" readonly/></div>
    <input id="sliderVariable" type="hidden"/>

    <div class="buttons">
        <button id="styleReloadLink" onclick="getImageStyle()">SET STYLE</button>
    </div>
</div>

<!--div id="mainbodyPadding" -->


<div id="mainbody">

    <div class="ui-layout-north auvHeader">
        <div class="toplinks">

            <a target="_blank" href="http://www.emii.org.au" title="e-Marine Information Infrastructure"
               class="leftmenu_ahref ">eMII Home</a>
            <a target="_blank" href="http://www.imos.org.au" title="Integrated Marine Observing System"
               class="leftmenu_ahref ">IMOS Home</a>
        </div>

        <div id="logo">
            <a class="noTextDecoration" href="http://imos.org.au/auv.html"><img src="images/IMOS_AUV_logo.png"
                                                                                height="60"
                                                                                alt="IMOS Logo"/>
            </a>
        </div>

        <div class="title">
            <h1>Autonomous Underwater Vehicle</h1>

            <h3>Images Viewer</h3>
        </div>

    </div>

    <div id="mapcontainer" class="ui-layout-west">

        <div id="mapWrapper">
            <div id="map">
                <div id="controlPanZoom"></div>
            </div>
        </div>

        <div id="controlWrapper">
            <div id="mapscale"></div>

            <div id="mapcoords"></div>

            <div id="styles" style="display:none">
                <!--select id="imageFormatSelector"  onFocus="openStyleSlider('dummy')" onChange="openStyleSlider(value)" >
                      <option class="defaultLabel" selected="selected">Image layer Style</option>
                        <option value="default"  >Default</option>
                          <option value="depth" >Bathymetry</option>
                          <option value="sea_water_temperature" >Temperature</option>
                    </select-->

            </div>

            <div id="legendToggle">Legend</div>

        </div>

        <div id="footer" class="ui-layout-soouth">

            <div class="footerLogos">
                <img class="logo" alt="DIISTRE Logo" target="_blank"
                     src="https://static.emii.org.au/images/logo/NCRIS_Initiative_stacked110.png"/>
                <a href="http://www.utas.edu.au/" target="_blank"><img class="logo" alt="UTAS Logo"
                                                                       src="https://static.emii.org.au/images/logo/utas/UTAS_MONO-onwhite_Stacked_104w.png"/>
                </a>
            </div>

            <p>IMOS is a national collaborative research infrastructure, supported by Australian Government. It is led by University of Tasmania in partnership with the Australian marine &amp; climate science community.
            </p>

            <p>
                <a href=" http://help.aodn.org.au/help/?q=node/81" target="_blank"
                   title="Data usage acknowledgement">Acknowledgement</a>
                <b>|</b>
                <a href=" http://help.aodn.org.au/help/?q=node/80" target="_blank"
                   title="Disclaimer information">Disclaimer</a>
            </p>

        </div>

    </div>


    <div id="imagecontainer" class="ui-layout-center">

        <div id="helpSection">
            <h3>How to use this AUV image viewer</h3>

            <ol>
                <li>Click on a AUV Icon, or choose from the track list.
                <li>Choose a track and the map will zoom to it.
                <li>Click on a track to view the closest images to the click origin.
                <li>Optionally sort images along the track for the currently highlighted image.
                <li>Click on any image to view or add notes about the image contents.
            </ol>
        </div>

        <div id="mygallery" class="stepcarousel">

            <div class="belt">
                <div class="panel">
                    <img src="images/mapshadow.png"/>
                </div>
            </div>
        </div>

        <div id="galleryControls" style="height:360px">
            <div id="trackSelectorDiv" class="ui-layout-north buttons">
                <select name="trackSelector" id="trackSelector">
                    <option id="default" value="default">... Choose a AUV Track...</option>
                </select>
                <button onclick="resetMap()" id="resetmap">RESET MAP</button>

                <div id="loader">Loading...
                    <img alt="loading..." src="images/loading.gif">
                </div>

                <h3 id="thisTrackInfo">&nbsp;</h3>

            </div>

            <div id="trackcontainer" class="ui-layout-west">

                <div id="track_html"></div>
            </div>

            <div class="ui-layout-center">
                <div id="stepcarouselcontrols">
                    <p id="unsorted_status">
                        <b>Current Viewing Images:</b> <span id="statusA"></span> to <span
                            id="statusB"></span><b>of:</b> <span id="statusC"></span> <b>near your click point</b>
                    </p>

                    <div id="sliderContainer">
                        <div id="slider"></div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
