package auv

class Login {

    String userid
    String title
    String firstname
    String lastname
    String institution
    String email
    String joindate

    static constraints = {

        userid(unique:true,blank:false)
        email(email:true,blank:false)
        firstname(blank:false)
        title(inList:['Mr','Mrs','Ms','Dr','Professor'])

    }




}
