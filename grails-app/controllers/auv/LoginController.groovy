//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under 
//  the terms of the GNU General Public License
//*************************************************//


package auv


//import groovyx.net.http.*
//import static groovyx.net.http.ContentType.XML
//import groovy.xml.MarkupBuilder
//@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.5.0')







class LoginController {

    def index = { redirect(index:Finder,params:params) }
    
  /*
    
    static defaultAction = "entry"
    def Scaffold = Login
    
    def list = {
        redirect(action:entry,params:params)
    }

	def logout = {
		log.info "User agent: " + request.getHeader("User-Agent")
        def img = session.imageUrl
		session.invalidate()
		redirect(controller:'finder')
	}
    
	def entry = {

        def username = "pmbohm" // hard coded

        def writer = new StringWriter()
        def xml = new MarkupBuilder(writer)
        //def http = new HTTPBuilder("http://localhost:8080/geonetwork/srv/en/xml.user.login")

        xml.request() {
            // delegate to get a tag username while using the value 'username'
            delegate.username username
        }

        def  response = xml.toURL()

        println response
        // could possibley supply username and password
         [login:params]
    }

    def create = {

         [details:params]
         //def user = Login.findWhere(email:params['email'],  password:params['password'])
        // def http = new HTTPBuilder("http://localhost:8080/geonetwork/srv/en/xml.user.login")

        //def postBody = [username:'admin',password:'password'] // will be url-encoded


        //flash.message = loginStr.toURL()
        
         render(view: "newUser")
    }
    def save = {

         [details:params]
         render(view: "entry")
    }

    def doLogin = {
        

        // email is the username
        // validate the supplied email
        def login = new Login(params)

        if(login.validate()) {

            session.username = params.email
            // if this login came from the notes window
            // if (session.imageUrl) {
            //    redirect(controller:'notes', params:["src": session.imageUrl])
            // }
             // login came through home page link
            // else {
                 redirect(controller:'finder')
            // }

        }
        else {
            flash.message = "Please enter your email address and password"
            login.errors.allErrors.each {
                println it
            }

            render(view: "entry", model: [login: params] )
        }
    }

    def newUser = {
         [login:params]
    }

    */



}
