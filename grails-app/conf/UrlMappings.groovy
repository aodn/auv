//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under 
//  the terms of the GNU General Public License
//*************************************************//


class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}


        // map this to the notes part for now
        // add the orignal index page latter
		"/"  {
            controller = "finder"
            //view = "notes"
        }

        // todo write a decent non grails error page
		"500"(view:'/error')

	}
}
