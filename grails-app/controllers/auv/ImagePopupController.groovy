//*************************************************/
// Copyright 2010 IMOS
// The IMOS AUV Viewer is distributed under
// the terms of the GNU General Public License
/*************************************************/
package auv

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
