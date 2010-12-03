package auv

class LoginController {

    //def index = { redirect(action:login,params:params) }

    
    static defaultAction = "entry"
    def Scaffold = Login
    
    def list = {
        redirect(action:entry,params:params)
    }

	def logout = {
		log.info "User agent: " + request.getHeader("User-Agent")
        def img = session.imageUrl
		session.invalidate()
		redirect(controller:'notes', params:["src": img ])
	}
    
	def entry = {

        // could possibley supply uername and password
         [login:params]
    }

    def create = {

         [details:params]
         render(view: "newUser")
    }
    def save = {

         [details:params]
         render(view: "entry")
    }

    def doLogin = {
        //def user = Login.findWhere(email:params['email'],  password:params['password'])

        // email is the username
        // validate the supplied email
        def login = new Login(params)

        if(login.validate()) {
            flash.username = params.email
            redirect(controller:'notes', params:["src": session.imageUrl])
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




}
