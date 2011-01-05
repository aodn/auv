package auv


//mport groovyx.net.http.HttpClient
//import groovyx.net.http.HTTPBuilder
//import groovyx.net.http.HttpResponseException
//import static groovyx.net.http.Method.GET
//import static groovyx.net.http.ContentType.TEXT

class ProxyController {

    def index = {

        if (params.url) {
        
           //exclude use to certain hosts
           def hostList = ['localhost:8080','preview.emii.org.au','imos1.ersa.edu.au']
           def host = request.getHeader('host')

           if  (hostList.any { host }) {
             def thetext = params.url.toURL()
             render(text: thetext.text ,contentType:"text/xml",encoding:"UTF-8")
           }
           else {
               render(text: "Host not allowed",contentType:"text/html",encoding:"UTF-8")
           }

        }
        else {
             render(text: "No URL supplied",contentType:"text/html",encoding:"UTF-8")
        }

    
        
        
    }
}
