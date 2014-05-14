//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under
//  the terms of the GNU General Public License
//*************************************************//


package auv

class ProxyController {

    def grailsApplication

    def index = {
        if (params.url) {

            // restrict use to certain hosts
            def hostList = [
                grailsApplication.config.geoserver.url.toURL().getHost()
            ]

            def format
            def thetext = params.url.toURL()

            // get the domain name from the supplied uri
            def hostName = params.url.toURL().getHost()

            if (hostList.contains(hostName)) {

                log.info("Proxy: The url to be requested " + thetext)
                if (params.format == "xml") {
                    format = "text/xml"
                } else {
                    format = "text/html"
                }
                render(text: thetext.text, contentType: format, encoding: "UTF-8")
            }
            else {
                log.error("Proxy: The url " + thetext.text + "was not allowed")
                render(text: "Host not allowed", contentType: "text/html", encoding: "UTF-8")
            }
        }
        else {
            render(text: "No URL supplied", contentType: "text/html", encoding: "UTF-8")
        }
    }
}
