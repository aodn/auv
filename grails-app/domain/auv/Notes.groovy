package auv

class Notes {

    
    String username
    String image_filename
    Date datetime
    String note
    String imagex1
    String imagex2
    String imagey1
    String Imagey2

    static constraints = {

        note(maxSize:1000, nullable:true, widget:'textarea')
        username(blank:false, length:0..30)
        datetime(blank:false)
        image_filename(blank:false)
        imagex1(blank:false)
        imagex2(blank:false)
        imagey1(blank:false)
        imagey2(blank:false)


    }

    

    def submitNote = {
        print "got to the notes submitNote Domain handler"
    }

}
