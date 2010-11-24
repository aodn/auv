package auv

class NotesController {

    //static defaultAction = "submitNote"
    def getNotes() {
        def query = "from Notes where image_filename like '" + session.image + "' order by datetime desc"
        //session.currentnotes = Notes.findAllWhere(image_filename: session.image)
        session.currentnotes = Notes.findAll(query)
    }


    def index = {

        session.username = "test-user2"

        if (params.src != "") {
            session.imageUrl = params.src
            def file = params.src.split("/")
            session.image = file[file.size() -1]
        }      
        getNotes()         
    }

    def edit =  {

        def theNote = Notes.findWhere(id: Long.parseLong(params.id))
        if (theNote) {
            if (session.username == theNote.username) {
                //theNote.delete(flush:true)      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  much more to do
            }
        }
        render(view: "index")
    }
    
    
    def delete = {

        // find the culprit
        def theNote = Notes.findWhere(id: Long.parseLong(params.id))
        if (theNote) {
            if (session.username == theNote.username) {
                theNote.delete(flush:true)
            }
        }

        getNotes()
        render(view: "index" )
    }


    def submitNote = {    

        if (request.method != "GET") {

            // check for previous identical entry
            boolean isSaved = Notes.findWhere(
                username: session.username,
                image_filename: session.image,
                note: params.newNote,
                imagex1: params.imageX1,
                imagex2: params.imageX2,
                imagey1: params.imageY1,
                imagey2: params.imageY2,
                width: params.width,
                height: params.height
            ) != null
            
            if (!isSaved) {

                // do some saving of the params
                def aNote = new Notes()
                aNote.username =  session.username
                aNote.image_filename= session.image
                aNote.datetime= new Date()
                aNote.note= params.newNote
                aNote.imagex1= params.imageX1
                aNote.imagex2= params.imageX2
                aNote.imagey1= params.imageY1
                aNote.imagey2= params.imageY2
                aNote.width= params.width
                aNote.height= params.height
                aNote.save(flush:true)  // flush:true = save immediately
            }

        }

        getNotes()
        render(view: "index" )

    }

    
}
