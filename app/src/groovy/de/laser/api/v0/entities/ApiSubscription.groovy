package de.laser.api.v0.entities


import de.laser.Identifier
import de.laser.Org
import de.laser.OrgRole
import de.laser.Subscription
import de.laser.finance.CostItem
import de.laser.api.v0.*
import de.laser.helper.Constants
import de.laser.helper.RDStore
import grails.converters.JSON
import groovy.util.logging.Log4j
import org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsHibernateUtil

@Log4j
class ApiSubscription {

    /**
     * @return ApiBox(obj: Subscription | null, status: null | BAD_REQUEST | PRECONDITION_FAILED | NOT_FOUND | OBJECT_STATUS_DELETED)
     */
    static ApiBox findSubscriptionBy(String query, String value) {
		ApiBox result = ApiBox.get()

        switch(query) {
            case 'id':
				result.obj = Subscription.findAllWhere(id: Long.parseLong(value))
                break
            case 'globalUID':
				result.obj = Subscription.findAllWhere(globalUID: value)
                break
            case 'ns:identifier':
				result.obj = Identifier.lookupObjectsByIdentifierString(new Subscription(), value)
                break
            default:
				result.status = Constants.HTTP_BAD_REQUEST
				return result
                break
        }
		result.validatePrecondition_1()

		/*if (result.obj instanceof Subscription) {
			result.validateDeletedStatus_2('status', RDStore.SUBSCRIPTION_DELETED)
		}*/
		result
    }

    /**
     * @return boolean
     */
    static boolean calculateAccess(Subscription sub, Org context) {

		boolean hasAccess = false

		if (! sub.isPublicForApi) {
			hasAccess = false
		}
		else if (OrgRole.findBySubAndRoleTypeAndOrg(sub, RDStore.OR_SUBSCRIPTION_CONSORTIA, context)) {
			hasAccess = true
		}
		else if (OrgRole.findBySubAndRoleTypeAndOrg(sub, RDStore.OR_SUBSCRIBER, context)) {
			hasAccess = true
		}
		else if (OrgRole.findBySubAndRoleTypeAndOrg(sub, RDStore.OR_SUBSCRIBER_CONS, context)) {
			hasAccess = true
		}

        hasAccess
    }

    /**
     * @return JSON | FORBIDDEN
     */
    static requestSubscription(Subscription sub, Org context, boolean isInvoiceTool){
        Map<String, Object> result = [:]

		boolean hasAccess = isInvoiceTool || calculateAccess(sub, context)
        if (hasAccess) {
            result = getSubscriptionMap(sub, ApiReader.IGNORE_NONE, context, isInvoiceTool)
        }

        return (hasAccess ? new JSON(result) : Constants.HTTP_FORBIDDEN)
    }

    /**
     * @return JSON
     */
    static JSON getSubscriptionList(Org owner, Org context){
        Collection<Object> result = []

        List<Subscription> available = Subscription.executeQuery(
                'SELECT DISTINCT(sub) FROM Subscription sub JOIN sub.orgRelations oo WHERE oo.org = :owner AND oo.roleType in (:roles )' ,
                [
                        owner: owner,
                        roles: [RDStore.OR_SUBSCRIPTION_CONSORTIA, RDStore.OR_SUBSCRIBER_CONS, RDStore.OR_SUBSCRIBER]
                ]
        )

		println "${available.size()} available subscriptions found .."

        available.each { sub ->
			result.add(ApiStubReader.requestSubscriptionStub(sub, context))
        }

		ApiToolkit.cleanUpDebugInfo(result)

		return (result ? new JSON(result) : null)
    }

	/**
	 * @return Map<String, Object>
	 */
	static Map<String, Object> getSubscriptionMap(Subscription sub, def ignoreRelation, Org context, boolean isInvoiceTool){
		Map<String, Object> result = [:]

		sub = GrailsHibernateUtil.unwrapIfProxy(sub)

		result.globalUID            	= sub.globalUID
		result.cancellationAllowances 	= sub.cancellationAllowances
		result.dateCreated          	= ApiToolkit.formatInternalDate(sub.dateCreated)
		result.endDate              	= ApiToolkit.formatInternalDate(sub.endDate)
		result.lastUpdated          	= ApiToolkit.formatInternalDate(sub._getCalculatedLastUpdated())
		result.manualCancellationDate 	= ApiToolkit.formatInternalDate(sub.manualCancellationDate)
		result.manualRenewalDate    	= ApiToolkit.formatInternalDate(sub.manualRenewalDate)
		result.name                 	= sub.name
		result.noticePeriod         	= sub.noticePeriod
		result.startDate            	= ApiToolkit.formatInternalDate(sub.startDate)
		result.calculatedType       	= sub._getCalculatedType()

		// RefdataValues

		result.form         		= sub.form?.value
		result.isSlaved     		= sub.isSlaved ? 'Yes' : 'No'
        result.isMultiYear  		= sub.isMultiYear ? 'Yes' : 'No'
		result.resource     		= sub.resource?.value
		result.status       		= sub.status?.value
		result.type         		= sub.type?.value
		result.kind         		= sub.kind?.value
		result.isPublicForApi 		= sub.isPublicForApi ? 'Yes' : 'No'
		result.hasPerpetualAccess 	= sub.hasPerpetualAccess ? 'Yes' : 'No'

		// References

		result.documents            = ApiCollectionReader.getDocumentCollection(sub.documents) // de.laser.DocContext
		//result.derivedSubscriptions = ApiStubReader.getStubCollection(sub.derivedSubscriptions, ApiReader.SUBSCRIPTION_STUB, context) // com.k_int.kbplus.Subscription
		result.identifiers          = ApiCollectionReader.getIdentifierCollection(sub.ids) // de.laser.Identifier
		result.instanceOf           = ApiStubReader.requestSubscriptionStub(sub.instanceOf, context) // com.k_int.kbplus.Subscription
		//result.organisations        = ApiCollectionReader.resolveOrgLinks(sub.orgRelations, ApiCollectionReader.IGNORE_SUBSCRIPTION, context) // de.laser.OrgRole
		result.orgAccessPoints			= ApiCollectionReader.getOrgAccessPointCollection(sub.getOrgAccessPointsOfSubscriber())

		result.predecessor = ApiStubReader.requestSubscriptionStub(sub._getCalculatedPrevious(), context) // com.k_int.kbplus.Subscription
		result.successor   = ApiStubReader.requestSubscriptionStub(sub._getCalculatedSuccessor(), context) // com.k_int.kbplus.Subscription
		result.properties  = ApiCollectionReader.getPropertyCollection(sub, context, ApiReader.IGNORE_NONE) // com.k_int.kbplus.(SubscriptionCustomProperty, SubscriptionPrivateProperty)

		def allOrgRoles = []

		// add derived subscriptions org roles
		if (sub.derivedSubscriptions) {
			allOrgRoles = OrgRole.executeQuery(
					"select oo from OrgRole oo where oo.sub in (:derived) and oo.roleType in (:roles)",
					[derived: sub.derivedSubscriptions, roles: [RDStore.OR_SUBSCRIBER_CONS, RDStore.OR_SUBSCRIBER]]
			)
		}
		allOrgRoles.addAll(sub.orgRelations)

		result.organisations = ApiCollectionReader.getOrgLinkCollection(allOrgRoles, ApiReader.IGNORE_SUBSCRIPTION, context) // de.laser.OrgRole

		// TODO refactoring with issueEntitlementService
		result.packages = ApiCollectionReader.getPackageWithIssueEntitlementsCollection(sub.packages, context) // de.laser.SubscriptionPackage

		// Ignored

		//result.packages = exportHelperService.resolvePackagesWithIssueEntitlements(sub.packages, context) // de.laser.SubscriptionPackage
		//result.issueEntitlements = exportHelperService.resolveIssueEntitlements(sub.issueEntitlements, context) // de.laser.IssueEntitlement
		//result.packages = exportHelperService.resolveSubscriptionPackageStubs(sub.packages, exportHelperService.IGNORE_SUBSCRIPTION, context) // de.laser.SubscriptionPackage
		/*
		result.persons      = exportHelperService.resolvePrsLinks(
				sub.prsLinks,  true, true, context
		) // de.laser.PersonRole
		*/

		//result.license = ApiStubReader.requestLicenseStub(sub.owner, context) // com.k_int.kbplus.License
		result.licenses = []
		sub.getLicenses().each { lic ->
			result.licenses.add( ApiStubReader.requestLicenseStub(lic, context) )
		}

		if (isInvoiceTool) {
			result.costItems = ApiCollectionReader.getCostItemCollection(sub.costItems)
		}
		else {
			Collection<CostItem> filtered = sub.costItems.findAll{ it.owner == context || it.isVisibleForSubscriber }

			result.costItems = ApiCollectionReader.getCostItemCollection(filtered)
		}

		ApiToolkit.cleanUp(result, true, true)
	}
}
