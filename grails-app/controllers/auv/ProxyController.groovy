//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under 
//  the terms of the GNU General Public License
//*************************************************//


package auv



class ProxyController {

    def index = {

        if (params.url) {
        
           //exclude use to certain hosts
           def hostList = ['imos2.ersa.edu.au']
           def format

           // get the doamin name from the supplied uri
           def hostName =  params.url.toURL().getHost()

            if (hostList.contains(hostName)) {

                 def thetext = params.url.toURL()
                 log.info("Proxy: The url to be requested " + thetext)
                 if (params.format == "xml") {
                     format = "text/xml"
                 }
                 else {
                     format = "text/html"
                 }
                 render(text: thetext.text ,contentType:format,encoding:"UTF-8")

           }
           else {
               log.error("Proxy: The url " + thetext.text + "was not allowed")
               render(text: "Host not allowed",contentType:"text/html",encoding:"UTF-8")
           }


        }
        else {
             render(text: "No URL supplied",contentType:"text/html",encoding:"UTF-8")
        }

    }
    
}
