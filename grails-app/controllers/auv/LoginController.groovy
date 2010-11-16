package auv

class LoginController {

    def index = { redirect(action:login,params:params) }

    def Scaffold = Login

	def logout = {
		log.info "User agent: " + request.getHeader("User-Agent")
		session.invalidate()
		redirect(action:"login")
	}
	def login = {

    }

}
