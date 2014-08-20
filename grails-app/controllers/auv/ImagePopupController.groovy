package auv

/**
 * Created by pmbohm on 20/08/14.
 */
class ImagePopupController {
    def index = {

        if (params.jpg) {

            [params: params]
        }
        else {
            render text: 'ERROR: There was no image supplied to show!', status: 404
        }
    }

}
