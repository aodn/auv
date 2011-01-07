package auv

class NotesController {

    /*def beforeInterceptor = [action:this.&auth]
    def auth() {         if(!session.user) {
            redirect(controller:'authentication',action:'login')             return false         }     }
            */
    //static defaultAction = "submitNote"
    def getNotes() {
        def query = "from Notes where image_filename like '" + session.image + "' order by datetime desc"
        //session.currentnotes = Notes.findAllWhere(image_filename: session.image)
        session.currentnotes = Notes.findAll(query)
    }


    def index = {
        

        if (params.src) {
            
            session.imageUrl = params.src
            session.tiffImageUrl = params.tiff

            def file = params.src.split("/")
            session.image = file[file.size() -1]
        }  
        else if(!session.imageUrl) {
            render("ERROR: There was no image supplied to annotate!")
        }

        getNotes()         
    }

    def getNoteToEdit =  {

        def theNote = Notes.findWhere(id: Long.parseLong(params.id))
        if (theNote) {
            if (session.username == theNote.username) {
                
            }
        }        
        render(view: "edit", model: [theNote: theNote] )
       
    }


    def editNote =  {

        def theNote = Notes.findWhere(id: Long.parseLong(params.id))
        if (theNote) {
            if (session.username == theNote.username) {
                
                theNote.username =  session.username
                theNote.image_filename= session.image
                theNote.datetime= new Date()
                theNote.note= params.editedNote
                theNote.imagex1= params.imageX1
                theNote.imagex2= params.imageX2
                theNote.imagey1= params.imageY1
                theNote.imagey2= params.imageY2
                theNote.width= params.width
                theNote.height= params.height
                theNote.save(flush:true)  // flush:true = save immediately

                flash.message = "Successful edit"
            }
            else {
                flash.message = "You may only edit your own notes."
            }
        }
        redirect(action:"index", params:[src: session.imageUrl ])

    }
    
    
    def delete = {

        // find the culprit
        def theNote = Notes.findWhere(id: Long.parseLong(params.id))
        if (theNote) {
            if (session.username == theNote.username) {
                theNote.delete(flush:true)
            }
            else {
                    flash.error = "You may only delete your own notes."
            }
        }
        else {
             flash.error = "The note dosen't exist"
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
