//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under
//  the terms of the GNU General Public License
//*************************************************//

package auv

class FinderController {
    def grailsApplication

    // Display the AUV main map
    def index = {

        if (params.lat != null && params.lon != null) {
            flash.zoom = true
            flash.lat = params.lat
            flash.lon = params.lon
        }

        [geoserver: grailsApplication.config.geoserver]
    }
}
