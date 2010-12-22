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
            dbCreate = "create-drop" // one of 'create', 'create-drop','update'
            url = "jdbc:postgresql://localhost:5432/auvusers"
            username = "auv"
            password = "heyuv8"
        }
    }
    test {
        dataSource {
            dbCreate = "create-drop" // one of 'create', 'create-drop','update'
            jndiName = "java:comp/env/jdbc/auvusers"
            //url = "jdbc:postgresql://dbfarm0.emii.org.au:5432/auvusers"
            username = "auv"
            password = "heyuv8"
        }
    }
   production {
        dataSource {
            dbCreate = "update" // one of 'create', 'create-drop','update'
            jndiName = "java:comp/env/jdbc/auvusers"
            username = "auv"
            password = "heyuv8"
        }
    }

}
