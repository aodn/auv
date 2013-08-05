//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under 
//  the terms of the GNU General Public License
//*************************************************//


package auv


class FinderController {


    def server = "http://geoserver.imos.org.au"
    def serverContext = "geoserver"
    def layernameTrack = "helpers:auv_tracks"
    def layernameImages = "helpers:auv_images_vw"


    // Display the AUV main map
    def index = {

            if (params.lat != null && params.lon != null) {
                flash.zoom = true
                flash.lat = params.lat
                flash.lon= params.lon
            }
         [  server: server,
            serverContext: serverContext,
            layernameTrack: layernameTrack,
            layernameImages: layernameImages
         ] 
    }
}
