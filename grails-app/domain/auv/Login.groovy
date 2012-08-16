//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under 
//  the terms of the GNU General Public License
//*************************************************//


package auv

class Login {

    //String title
    //String firstname
    //String surname
    //String org
    //String kind //kind of organisation
    //String address
    //String zip
    //String country
    String email
    String password
    //String joindate

    static constraints = {

        //title(inList:['Mr','Mrs','Ms','Dr','Professor'])
        //kind(inList:['Government','NGO','University','Private Sector','Volunteer'])
        email(email:true,unique:true,blank:false)
        password(size:5..15, blank:false)

       /* title(blank:true)
        firstname(blank:true)
        surname(blank:true)
        org(blank:true)
        kind(blank:true)
        address(blank:true)
        zip(blank:true)
        country(blank:true)
        joindate(blank:true)
        */

    }




}
