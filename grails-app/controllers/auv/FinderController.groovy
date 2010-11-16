package auv

class FinderController {

    def index = {



                def server = "http://geoserver.emii.org.au"
                def layernameTrack = "topp:auv_tracks"
                def layernameImages = "topp:auv_images_vw"


                // get the server name to choose proxy latter
                def serverName =  request.getHeader("HTTP_HOST")


                [ server, layernameTrack, layernameImages, serverName ]

    }
}
