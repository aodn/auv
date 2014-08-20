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

    <g:render template="auv_functions_js"></g:render>
    <g:render template="finder_js"></g:render>
</head>

<body>

<div id="loading_cover"></div>


<div id="legend" class="jqDnR jqDrag" style="display:none">
    <img id="legendClose" alt="Close popup" class="right closeIcon" src="images/close.png"/>

    <h3>Track:</h3>
    <img src="${geoserver.url}/wms?LAYER=${geoserver.layerNames.tracks}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" alt="Legend for ${geoserver.layerNames.tracks}"/>

    <h3>Images:</h3>
    <img id="imagesGetLegendGraphic" src="${geoserver.url}/wms?LAYER=${geoserver.layerNames.tracks}&LEGEND_OPTIONS=forceLabels:on&REQUEST=GetLegendGraphic&FORMAT=image/png" alt="Legend for ${geoserver.layerNames.images}"/>
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

    <div id="logo" class="ui-layout-north">
        <a class="noTextDecoration" href="http://imos.org.au/auv.html"><img src="images/IMOS_AUV_logo.png" height="70" width="403" alt="IMOS Logo"/>
        </a>
        <div class="toplinks">
            <g:if test="${false}">
                <g:if test="${session.username}">
                    <g:link controller="login" action="logout">logout</g:link> ${session.username}</g:if>
                <g:else>
                    <a href="login" title="Login and view your stored searches and maps" class="leftmenu_ahref ">Login</a>
                </g:else>
            </g:if>

            <a target="_blank" href="http://www.emii.org.au" title="e-Marine Information Infrastructure" class="leftmenu_ahref ">eMII Home</a>
            <a target="_blank" href="http://www.imos.org.au" title="Integrated Marine Observing System" class="leftmenu_ahref ">IMOS Home</a>
        </div>

        <h1>Autonomous Underwater Vehicle Images Viewer</h1>

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

            <div>
                <img class="logo" alt="DIISTRE Logo" target="_blank" src="http://static.emii.org.au/images/logo/NCRIS_Initiative_stacked110.png" />
                <a href="http://www.utas.edu.au/" target="_blank" ><img  class="logo" alt="UTAS Logo" src="http://static.emii.org.au/images/logo/utas/UTAS_MONO-onwhite_Stacked_104w.png" /></a>
                <a class="external" title="Creative Commons License" href="http://creativecommons.org/licenses/by/3.0/au/" target="_blank"><img src="images/by.png" width="80"></a>
            </div>
            <p>This site is licensed under a <a title="Creative Commons License" href="http://creativecommons.org/licenses/by/3.0/au/" target="_blank">Creative Commons Attribution 3.0 Australia License</a> &nbsp;

            <BR/>

            <a href="http://www.imos.org.au" title="Integrated Marine Observing System">IMOS</a> is a national collaborative research infrastructure, supported by Australian Government.  It is led by <a href="http://www.utas.edu.au/">University of Tasmania</a> in partnership with the Australian marine & climate science community.<BR/>You accept all risks and responsibility for losses, damages, costs and other consequences resulting directly or indirectly from using this site and any information or material available from it.<BR/>If you have any concerns about the veracity of the data, please make enquiries via <a href="mailto:info@emii.org.au">info@emii.org.au</a> to be directed to the data custodian.<br/>IMOS data is made freely available under the <a href="http://imos.org.au/fileadmin/user_upload/shared/IMOS%20General/documents/internal/IMOS_Policy_documents/Policy-Acknowledgement_of_use_of_IMOS_data_11Jun09.pdf" title="conditions of use">Conditions of Use.</a><br/>
            Created by <a href="http://imos.org.au/emii.html" title="eMarine Information Infrastructure">eMII</a> &nbsp;
            <a href="http://www.imos.org.au" title="Integrated Marine Observing System">&copy; IMOS Australia</a>  &nbsp;
            Comments on this site? Contact us at <a href="mailto:info@emii.org.au">info@emii.org.au</a></p>
            <BR/>

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
                        <b>Current Viewing Images:</b> <span id="statusA"></span> to <span id="statusB"></span><b>of:</b> <span id="statusC"></span> <b>near your click point</b>
                    </p>

                    <p id="sorted_status"></p>


                    <div class="trackSort"><a href="javascript:sortImagesAlongTrack('left')">Older&nbsp;</a></div>

                    <div id="sliderContainer">
                        <div id="slider"></div>
                    </div>

                    <div class="trackSort"><a href="javascript:sortImagesAlongTrack('right')">&nbsp;Later</a></div>


                    <div id="stepcarouselreorder"></div>

                    <div class="buttons">

                        <button href="#" onclick="sortImagesAlongTrack();
                        return false;" id="sortbytrack" style="display:none">Sort the Images along the<span>selected</span> track
                        </button>
                    </div>

                </div>
            </div>
        </div>

    </div>

</div>



<!--/div-->

</body>

</html>
