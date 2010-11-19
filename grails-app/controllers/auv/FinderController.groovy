package auv


class FinderController {

    // Display the AUV main map
    def index = {


        flash.message = "Welcome index page!"

        def server = "http://geoserverdev.emii.org.au"
        def layernameTrack = "topp:auv_tracks"
        def layernameImages = "topp:auv_images_vw"
        // get the server name to choose proxy latter
        def serverName =  request.getHeader("Host")



         [  server: server,
            layernameTrack: layernameTrack,
            layernameImages: layernameImages ,
            serverName: serverName
         ]
         //render(view: "../index")

 
    }
}
