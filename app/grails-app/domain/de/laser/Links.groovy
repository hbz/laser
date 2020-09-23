package de.laser


import com.k_int.kbplus.License
import com.k_int.kbplus.Org
import com.k_int.kbplus.Subscription
import de.laser.exceptions.CreationException

class Links {

    def contextService
    def springSecurityService
    def genericOIDService

    Long id
    String source
    String destination
    RefdataValue linkType
    Org     owner
    Date    dateCreated
    Date    lastUpdated

    static mapping = {
        id          column: 'l_id'
        source      column: 'l_source_fk',      index: 'l_source_idx'
        destination column: 'l_destination_fk', index: 'l_dest_idx'
        //objectType  column: 'l_object'
        linkType    column: 'l_link_type_rv_fk'
        owner       column: 'l_owner_fk'
        autoTimestamp true

        dateCreated column: 'l_date_created'
    }

    static constraints = {
        source        (blank: false)
        destination   (blank: false)
        //objectType    (blank: false)

        // Nullable is true, because values are already in the database
        dateCreated (nullable: true)

    }

    static Links construct(Map<String, Object> configMap) throws CreationException {
        withTransaction {
            Links links = new Links(source: configMap.source, destination: configMap.destination, owner: configMap.owner, linkType: configMap.linkType)
            if (links.save())
                links
            else {
                throw new CreationException(links.errors)
            }
        }
    }

    def getOther(key) {
        def context
        if(key instanceof Subscription || key instanceof License)
            context = genericOIDService.getOID(key)
        else if(key instanceof GString || key instanceof String)
            context = key
        else {
            log.error("No context key!")
            return null
        }

        if(context == source)
            return genericOIDService.resolveOID(destination)
        else if(context == destination)
            return genericOIDService.resolveOID(source)
        else return null
    }
}
