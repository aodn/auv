package auv


//mport groovyx.net.http.HttpClient
//import groovyx.net.http.HTTPBuilder
//import groovyx.net.http.HttpResponseException
//import static groovyx.net.http.Method.GET
//import static groovyx.net.http.ContentType.TEXT

class ProxyController {

    def index = {
        
        // TODO exclude use to certain hosts
        
         def thetext = params.url.toURL()
         render(text: thetext.text ,contentType:"text/xml",encoding:"UTF-8")

        /*
         // create a new builder
        def http = new HTTPBuilder( params.url )

        // get as text than render back out as XML
        http.request(GET, TEXT ) { req ->
                 // Switch to Java to set socket timeout
                 req.getParams().setParameter("http.socket.timeout", new Integer(5000))
                
                 response.success = { resp, text ->
                     println "Server Response: ${resp.statusLine}"
                     println "Server Type: ${resp.getFirstHeader('Server')}"
                     println "Content-Type: ${resp.headers.'Content-Type'}"
                     render(text: text.text ,contentType:"text/xml",encoding:"UTF-8")

                 }
                 response.failure = { resp ->
                    println resp.statusLine
                 }

        }
        */


        
        
        
    }
}
