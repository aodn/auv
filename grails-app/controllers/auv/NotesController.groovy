package auv

class NotesController {

    //static defaultAction = "submitNote"

    def index = {

        def image = params.src

        render(view: "notes")

         [ currentnotes : Notes.list(), image: image ]
    }
    
    
    //def Scaffold = Notes


    def submitNote = {
        
    
        def thisUsername = "test-user"
        // def user = User.get(session.user.id)
        
        if (request.method != "GET") {

            // do some saving of the params
            def aNote = new Notes()
            aNote.username = thisUsername
            aNote.image_filename= params.imageFilename
            aNote.datetime= new Date()
            aNote.note= params.newNote
            aNote.imagex1= params.imageX1
            aNote.imagex2= params.imageX2
            aNote.imagey1= params.imageY1
            aNote.imagey2= params.imageY2
            aNote.save()
        }

        redirect(action:index)
        

    }

    
}
