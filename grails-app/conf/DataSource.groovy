//*************************************************//
//  Copyright 2010 IMOS
//  The IMOS AUV Viewer is distributed under 
//  the terms of the GNU General Public License
//*************************************************//


dataSource {
    pooled = true
    driverClassName = "org.postgresql.Driver"
    dialect = org.hibernate.dialect.PostgreSQLDialect
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {

    development {
        dataSource {
            //dbCreate = "create-drop" // one of 'create', 'create-drop','update'
            url = "jdbc:postgresql://localhost:5432/auvusers"
            username = "auv"
            password = "auv"
        }
    }
    test {
        dataSource {
            dbCreate = "create-drop" // one of 'create', 'create-drop','update'
            jndiName = "java:comp/env/jdbc/auvusers"
        }
    }
   production {
        dataSource {
            //dbCreate = "update" // one of 'create', 'create-drop','update'
            jndiName = "java:comp/env/jdbc/auvusers"
        }
    }

}
