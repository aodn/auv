package auv


class FinderController {


    def server = "http://geoserver.emii.org.au"
    def layernameTrack = "topp:auv_tracks"
    def layernameImages = "topp:auv_images_vw"
    // get the server name to choose proxy latter
    def serverName =  request.getHeader("Host")

    // Display the AUV main map
    def index = {

            if (params.lat != null && params.lon != null) {
                flash.zoom = true
                flash.lat = params.lat
                flash.lon= params.lon
            }
         [  server: server,
            layernameTrack: layernameTrack,
            layernameImages: layernameImages ,
            serverName: serverName
         ] 
    }
}
