package de.laser

import com.k_int.kbplus.DocContext
import com.k_int.kbplus.GenericOIDService
import com.k_int.kbplus.IssueEntitlement
import com.k_int.kbplus.License
import com.k_int.kbplus.Org
import com.k_int.kbplus.Package
import com.k_int.kbplus.PendingChange
import com.k_int.kbplus.Subscription
import com.k_int.kbplus.SubscriptionPackage
import com.k_int.kbplus.TitleInstancePackagePlatform
import de.laser.helper.RDStore
import de.laser.interfaces.AbstractLockableService
import de.laser.interfaces.CalculatedType
import grails.transaction.Transactional
import org.codehaus.groovy.grails.plugins.DomainClassGrailsPlugin
import org.hibernate.Session

@Transactional
class StatusUpdateService extends AbstractLockableService {

    def globalSourceSyncService
    def changeNotificationService
    def contextService
    def propertyInstanceMap = DomainClassGrailsPlugin.PROPERTY_INSTANCE_MAP

    /**
     * Cronjob-triggered.
     * Runs through all subscriptions having status "Intended" or "Current" and checks their dates:
     * - if state = planned, then check if start date is reached, if so: update to active, else do nothing
     * - else if state = active, then check if end date is reached, if so: update to terminated, else do nothing
     */
    boolean subscriptionCheck() {
        if(!running) {
            running = true
            println "processing all intended subscriptions ..."
            Date currentDate = new Date()
            //Date currentDate = DateUtil.SDF_NoZ.parse("2020-05-30 03:00:00")

            Map<String,Object> updatedObjs = [:]

            // INTENDED -> CURRENT

            Set<Long> intendedSubsIds1 = Subscription.executeQuery('select s.id from Subscription s where s.status = :status and s.startDate < :currentDate and (s.endDate != null and s.endDate >= :currentDate) and s.isMultiYear = false',
            [status: RDStore.SUBSCRIPTION_INTENDED, currentDate: currentDate])

            log.info("Intended subscriptions reached start date and are now running (${currentDate}): " + intendedSubsIds1)

            if (intendedSubsIds1) {
                updatedObjs << ["intendedToCurrent (${intendedSubsIds1.size()})" : intendedSubsIds1]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_CURRENT, ids: intendedSubsIds1]
                )

                intendedSubsIds1.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_CURRENT)
                }
            }

            // MultiYear Sub INTENDED -> CURRENT

           Set<Long> intendedSubsIds2 = Subscription.executeQuery('select s.id from Subscription s where s.status = :status and ((s.instanceOf != null and s.instanceOf.startDate < :currentDate and s.instanceOf.endDate != null and s.instanceOf.endDate >= :currentDate) or '+
                   '(s.instanceOf = null and s.startDate < :currentDate and s.endDate != null and s.endDate >= :currentDate)) and s.isMultiYear = true',
                   [status: RDStore.SUBSCRIPTION_INTENDED, currentDate: currentDate])

            log.info("Intended perennial subscriptions reached start date and are now running (${currentDate}): " + intendedSubsIds2)

            if (intendedSubsIds2) {
                updatedObjs << ["MultiYear_intendedToCurrent (${intendedSubsIds2.size()})" : intendedSubsIds2]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_CURRENT, ids: intendedSubsIds2]
                )

                intendedSubsIds2.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_CURRENT)
                }
            }

            // INTENDED -> EXPIRED

            Set<Long> intendedSubsIds3 = Subscription.executeQuery('select s.id from Subscription s where s.status = :status and s.startDate < :currentDate and (s.endDate != null and s.endDate < :currentDate) and s.isMultiYear = false',
                    [status: RDStore.SUBSCRIPTION_INTENDED,currentDate: currentDate])

            log.info("Intended subscriptions reached start date and end date are now expired (${currentDate}): " + intendedSubsIds3)

            if (intendedSubsIds3) {
                updatedObjs << ["intendedToExpired (${intendedSubsIds3.size()})" : intendedSubsIds3]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_EXPIRED, ids: intendedSubsIds3]
                )

                intendedSubsIds3.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_EXPIRED)
                }
            }

            // MultiYear Sub INTENDED -> EXPIRED

            Set<Long> intendedSubsIds4 = Subscription.executeQuery('select s.id from Subscription s where s.status = :status and s.startDate < :currentDate and (s.endDate != null and s.endDate < :currentDate) and s.isMultiYear = true',
                    [status: RDStore.SUBSCRIPTION_INTENDED, currentDate: currentDate])

            log.info("Intended subscriptions reached start date and end date are now expired pernennial (${currentDate}): " + intendedSubsIds4)

            if (intendedSubsIds4) {
                updatedObjs << ["MultiYear_intendedToExpired (${intendedSubsIds4.size()})" : intendedSubsIds4]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_EXPIRED, ids: intendedSubsIds4]
                )

                intendedSubsIds4.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_EXPIRED)
                }
            }

            // CURRENT -> EXPIRED

            Set<Long> currentSubsIds = Subscription.executeQuery('select s.id from Subscription s where s.status = :status and s.startDate < :currentDate and (s.endDate != null and s.endDate < :currentDate) and s.isMultiYear = false',
                    [status: RDStore.SUBSCRIPTION_CURRENT, currentDate: currentDate])

            log.info("Current subscriptions reached end date and are now expired (${currentDate}): " + currentSubsIds)

            if (currentSubsIds) {
                updatedObjs << ["currentToExpired (${currentSubsIds.size()})" : currentSubsIds]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_EXPIRED, ids: currentSubsIds]
                )

                currentSubsIds.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_EXPIRED)
                }
            }

            // MultiYear Sub CURRENT -> EXPIRED

            Set<Long> currentSubsIds2 = Subscription.executeQuery('select s.id from Subscription s where s.status = :status and s.startDate < :currentDate and (s.endDate != null and ((s.instanceOf != null and s.instanceOf.endDate < :currentDate) or s.endDate < :currentDate)) and s.isMultiYear = true',
                [status: RDStore.SUBSCRIPTION_CURRENT,currentDate: currentDate])

            log.info("Current subscriptions reached end date and are now expired (${currentDate}): " + currentSubsIds2)

            if (currentSubsIds2) {
                updatedObjs << ["MultiYear_currentPerennialToExpired (${currentSubsIds2.size()})" : currentSubsIds2]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_EXPIRED, ids: currentSubsIds2]
                )

                currentSubsIds2.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_EXPIRED)
                }
            }

            // CURRENT PERENNIAL -> INTENDED PERENNIAL

            /*
            def currentSubsIds3 = Subscription.where {
                status == RDStore.SUBSCRIPTION_CURRENT && instanceOf.startDate > currentDate && (endDate != null && (instanceOf.endDate > currentDate)) && isMultiYear == true
            }.collect{ it.id }

            log.info("Current subscriptions reached end date and are now intended perennial (${currentDate}): " + currentSubsIds3)

            if (currentSubsIds3) {
                updatedObjs << ['currentPerennialToIntendedPerennial' : currentSubsIds3]

                Subscription.executeUpdate(
                        'UPDATE Subscription sub SET sub.status =:status WHERE sub.id in (:ids)',
                        [status: RDStore.SUBSCRIPTION_INTENDED_PERENNIAL, ids: currentSubsIds3]
                )

                currentSubsIds3.each { id ->
                    log.info('StatusUpdateService UPDATE subscriptions WHERE ID ' + id + ' Status: ' + RDStore.SUBSCRIPTION_INTENDED_PERENNIAL)
                }
            }**/

            SystemEvent.createEvent('SUB_UPDATE_SERVICE_PROCESSING', updatedObjs)
            running = false

            return true
        }
        else {
            log.warn("Subscription check already running ... not starting again.")
            return false
        }
    }

    /**
     * Cronjob-triggered.
     * Runs through all subscriptions having status "Intended" or "Current" and checks their dates:
     * - if state = planned, then check if start date is reached, if so: update to active, else do nothing
     * - else if state = active, then check if end date is reached, if so: update to terminated, else do nothing
     */
    boolean licenseCheck() {
        if(!running) {
            running = true
            println "processing all intended licenses ..."
            Date currentDate = new Date()

            Map<String,Object> updatedObjs = [:]

            // INTENDED -> CURRENT

            Set<Long> intendedLicsIds1 = License.executeQuery('select l.id from License l where l.status = :status and (l.startDate != null and l.startDate < :currentDate) and (l.endDate != null and l.endDate >= :currentDate)',
                    [status: RDStore.LICENSE_INTENDED,currentDate: currentDate])

            log.info("Intended licenses reached start date and are now running (${currentDate}): " + intendedLicsIds1)

            if (intendedLicsIds1) {
                updatedObjs << ["intendedToCurrent (${intendedLicsIds1.size()})" : intendedLicsIds1]

                Subscription.executeUpdate(
                        'UPDATE License lic SET lic.status =:status WHERE lic.id in (:ids)',
                        [status: RDStore.LICENSE_CURRENT, ids: intendedLicsIds1]
                )

                intendedLicsIds1.each { id ->
                    log.info('StatusUpdateService UPDATE license WHERE ID ' + id + ' Status: ' + RDStore.LICENSE_CURRENT)
                }
            }

            // CURRENT -> EXPIRED

            Set<Long> currentLicsIds = License.executeQuery('select l.id from License l where l.status = :status and (l.startDate != null and l.startDate < :currentDate) and (l.endDate != null and l.endDate < :currentDate)',
                    [status: RDStore.LICENSE_CURRENT, currentDate: currentDate])

            log.info("Current licenses reached end date and are now expired (${currentDate}): " + currentLicsIds)

            if (currentLicsIds) {
                updatedObjs << ["currentToExpired (${currentLicsIds.size()})" : currentLicsIds]

                Subscription.executeUpdate(
                        'UPDATE License lic SET lic.status =:status WHERE lic.id in (:ids)',
                        [status: RDStore.LICENSE_EXPIRED, ids: currentLicsIds]
                )

                currentLicsIds.each { id ->
                    log.info('StatusUpdateService UPDATE license WHERE ID ' + id + ' Status: ' + RDStore.LICENSE_EXPIRED)
                }
            }

            // INTENDED -> EXPIRED

            Set<Long> intendedLicsIds2 = License.executeQuery('select l.id from License l where l.status = :status and (l.startDate != null and l.startDate < :currentDate) and (l.endDate != null and l.endDate < :currentDate)',
                    [status: RDStore.LICENSE_INTENDED, currentDate: currentDate])

            log.info("Intended licenses reached start and end date and are now expired (${currentDate}): " + intendedLicsIds2)

            if (intendedLicsIds2) {
                updatedObjs << ["intendedToExpired (${intendedLicsIds2.size()})" : intendedLicsIds2]

                Subscription.executeUpdate(
                        'UPDATE License lic SET lic.status =:status WHERE lic.id in (:ids)',
                        [status: RDStore.LICENSE_EXPIRED, ids: intendedLicsIds2]
                )

                intendedLicsIds2.each { id ->
                    log.info('StatusUpdateService UPDATE license WHERE ID ' + id + ' Status: ' + RDStore.LICENSE_EXPIRED)
                }
            }

            SystemEvent.createEvent('LIC_UPDATE_SERVICE_PROCESSING', updatedObjs)
            running = false
        }
        else {
            log.warn("License check already running ... not starting again.")
            return false
        }
    }

    /**
     * Triggered from the Yoda menu
     * Refactors the preceding/following subscriptions to the new link model
     */
    int updateLinks() {
        int affected = 0
        List<Map<String,Subscription>> subsWithPrevious = Subscription.findAllByPreviousSubscriptionIsNotNull().collect { Subscription it -> [source:it,destination:it.previousSubscription] }
        subsWithPrevious.each { Map<String,Subscription> sub ->
            List<Links> linkList = Links.executeQuery('select l from Links as l where l.source = :source and l.destination = :destination and l.linkType = :linkType',[source:GenericOIDService.getOID(sub.source),destination:GenericOIDService.getOID(sub.destination),linkType:RDStore.LINKTYPE_FOLLOWS])
            if(linkList.size() == 0) {
                log.debug(sub.source+" follows "+sub.destination+", is being refactored")
                Links link = new Links()
                link.source = GenericOIDService.getOID(sub.source)
                link.destination = GenericOIDService.getOID(sub.destination)
                link.owner = Org.executeQuery('select o.org from OrgRole as o where o.roleType in :ownerRoles and o.sub in :context',[ownerRoles: [RDStore.OR_SUBSCRIPTION_CONSORTIA,RDStore.OR_SUBSCRIBER],context: [sub.source,sub.destination]]).get(0)
                link.linkType = RDStore.LINKTYPE_FOLLOWS
                if(!link.save(flush:true))
                    log.error("error with refactoring subscription link: ${link.errors}")
                affected++
            }
            else if(linkList.size() > 0) {
                log.debug("Link already exists: ${sub.source} follows ${sub.destination} is/are link/s ##${linkList}")
            }
        }
        affected
    }

    /**
     * Triggered from the Yoda menu
     * Sets the status of every subscription without start date to null as of ERMS-847
     */
    boolean startDateCheck() {
        def subsWithoutStartDate = Subscription.findAllByStartDateIsNullAndStatus(RDStore.SUBSCRIPTION_CURRENT).collect { it.id }
        if(subsWithoutStartDate) {
            Subscription.executeUpdate('UPDATE Subscription SET status = null where id IN (:subs)',[subs:subsWithoutStartDate])
            log.debug("Writing events")
            log.info("${subsWithoutStartDate.size()} subscriptions affected")
            return true
        }
        else {
            return false
        }
    }

    /**
     * Triggered from the Yoda menu
     * Loops through all IssueEntitlements and checks if there are inconcordances with their respective TIPPs. If so, and, if there is no pending change registered,
     * a new pending change is registered
     */
    void retriggerPendingChanges(String packageUUID) {
        Package pkg = Package.findByGokbId(packageUUID)
        Set<SubscriptionPackage> allSPs = SubscriptionPackage.findAllByPkg(pkg)
        //Set<SubscriptionPackage> allSPs = SubscriptionPackage.executeQuery('select sp from SubscriptionPackage sp where sp.subscription.status = :status and sp.pkg = :pkg and sp.subscription.instanceOf is null',[status:RDStore.SUBSCRIPTION_CURRENT,pkg:pkg]) //activate for debugging
        allSPs.each { SubscriptionPackage sp ->
            SubscriptionPackage.withNewSession { Session sess ->
                //for session refresh
                Set<IssueEntitlement> currentIEs = IssueEntitlement.executeQuery('select ie from IssueEntitlement ie where ie.status != :deleted and ie.subscription = :sub and ie.tipp.pkg = :pkg',[sub:sp.subscription,pkg:pkg,deleted:RDStore.TIPP_STATUS_DELETED])
                //A and B are naming convention for A (old entity which is out of sync) and B (new entity with data up to date)
                currentIEs.eachWithIndex { IssueEntitlement ieA, int index ->
                    Map<String,Object> changeMap = [target:ieA.subscription]
                    String changeDesc
                    if(ieA.tipp.status != RDStore.TIPP_STATUS_DELETED) {
                        TitleInstancePackagePlatform tippB = TitleInstancePackagePlatform.get(ieA.tipp.id) //for session refresh
                        Set<Map<String,Object>> diffs = globalSourceSyncService.getTippDiff(ieA,tippB)
                        diffs.each { Map<String,Object> diff ->
                            log.debug("now processing entry #${index}, payload: ${diff}")
                            if(diff.prop == 'coverage') {
                                //the city Coventry is beautiful, isn't it ... but here is the COVerageENTRY meant.
                                diff.covDiffs.each { covEntry ->
                                    def tippCov = covEntry.target
                                    switch(covEntry.event) {
                                        case 'update': IssueEntitlementCoverage ieCov = (IssueEntitlementCoverage) tippCov.findEquivalent(ieA.coverages)
                                            if(ieCov) {
                                                covEntry.diffs.each { covDiff ->
                                                    changeDesc = PendingChangeConfiguration.COVERAGE_UPDATED
                                                    changeMap.oid = GenericOIDService.getOID(ieA)
                                                    changeMap.prop = covDiff.prop
                                                    changeMap.oldValue = ieCov[covDiff.prop]
                                                    changeMap.newValue = covDiff.newValue
                                                    changeNotificationService.determinePendingChangeBehavior(changeMap,changeDesc,sp)
                                                }
                                            }
                                            else {
                                                changeDesc = PendingChangeConfiguration.NEW_COVERAGE
                                                changeMap.oid = GenericOIDService.getOID(tippCov)
                                                changeNotificationService.determinePendingChangeBehavior(changeMap,changeDesc,sp)
                                            }
                                            break
                                        case 'add':
                                            changeDesc = PendingChangeConfiguration.NEW_COVERAGE
                                            changeMap.oid = GenericOIDService.getOID(tippCov)
                                            changeNotificationService.determinePendingChangeBehavior(changeMap,changeDesc,sp)
                                            break
                                        case 'delete':
                                            IssueEntitlementCoverage ieCov = (IssueEntitlementCoverage) tippCov.findEquivalent(ieA.coverages)
                                            if(ieCov) {
                                                changeDesc = PendingChangeConfiguration.COVERAGE_DELETED
                                                changeMap.oid = GenericOIDService.getOID(ieCov)
                                                changeNotificationService.determinePendingChangeBehavior(changeMap,changeDesc,sp)
                                            }
                                            break
                                    }
                                }
                            }
                            else {
                                changeDesc = PendingChangeConfiguration.TITLE_UPDATED
                                changeMap.oid = GenericOIDService.getOID(ieA)
                                changeMap.prop = diff.prop
                                if(diff.prop in PendingChange.REFDATA_FIELDS)
                                    changeMap.oldValue = ieA[diff.prop].id
                                else if(diff.prop in ['hostPlatformURL'])
                                    changeMap.oldValue = diff.oldValue
                                else
                                    changeMap.oldValue = ieA[diff.prop]
                                changeMap.newValue = diff.newValue
                                changeNotificationService.determinePendingChangeBehavior(changeMap,changeDesc,sp)
                            }
                        }
                    }
                    else {
                        changeDesc = PendingChangeConfiguration.TITLE_DELETED
                        changeMap.oid = GenericOIDService.getOID(ieA)
                        changeNotificationService.determinePendingChangeBehavior(changeMap,changeDesc,sp)
                    }
                }
                Set<TitleInstancePackagePlatform> currentTIPPs = sp.subscription.issueEntitlements.collect { IssueEntitlement ie -> ie.tipp }
                Set<TitleInstancePackagePlatform> inexistentTIPPs = pkg.tipps.findAll { TitleInstancePackagePlatform tipp -> !currentTIPPs.contains(tipp) && tipp.status != RDStore.TIPP_STATUS_DELETED }
                inexistentTIPPs.each { TitleInstancePackagePlatform tippB ->
                    log.debug("adding new TIPP ${tippB} to subscription ${sp.subscription.id}")
                    changeNotificationService.determinePendingChangeBehavior([target:sp.subscription,oid:GenericOIDService.getOID(tippB)],PendingChangeConfiguration.NEW_TITLE,sp)
                }
                sess.flush()
                //sess.clear()
                //propertyInstanceMap.get().clear()
            }
        }
    }

    /**
     * Triggered from the Yoda menu
     * Loops through all {@link com.k_int.kbplus.Doc}ument objects without owner but with a {@link com.k_int.kbplus.DocContext} for a {@link Subscription} or {@link License} and assigns the ownership
     * to the respective subscriber/licensee.
     */
    void assignNoteOwners() {
        Set<DocContext> docsWithoutOwner = DocContext.executeQuery('select dc from DocContext dc where dc.owner.owner = null and (dc.subscription != null or dc.license != null)')
        docsWithoutOwner.each { DocContext dc ->
            Org documentOwner
            if(dc.subscription) {
                if(dc.isShared) {
                    if(dc.subscription._getCalculatedType() == CalculatedType.TYPE_CONSORTIAL)
                        documentOwner = dc.subscription.getConsortia()
                    else if(dc.subscription._getCalculatedType() == CalculatedType.TYPE_PARTICIPATION_AS_COLLECTIVE)
                        documentOwner = dc.subscription.getCollective()
                }
                else
                    documentOwner = dc.subscription.getSubscriber()
                log.debug("now processing note ${dc.owner.id} for subscription ${dc.subscription.id} whose probable owner is ${documentOwner}")
            }
            else if(dc.license) {
                documentOwner = dc.license.getLicensee()
                log.debug("now processing note ${dc.owner.id} for license ${dc.license.id} whose probable owner is ${documentOwner}")
            }
            if(documentOwner) {
                dc.owner.owner = documentOwner
                dc.owner.save()
            }
        }
    }

    /**
     * Triggered from the Admin menu
     * Takes every test subscription, processes them by name and counts their respective years up by one
     */
    def updateQASubscriptionDates() {
        //if someone changes the names, we are all screwed up since UUIDs may not persist when database is changed!
        List<String> names = ['Daten A (Test)','Daten A', 'E-Book-Pick', 'Journal-Paket', 'Journal-Paket_Extrem', 'Journal-Paket_extrem', 'Musterdatenbank', 'Datenbank', 'Datenbank 2']
        names.each { name ->
            List<Subscription> subscriptions = Subscription.findAllByName(name)
            subscriptions.each { sub ->
                log.debug("updating ${sub.name} of ${sub.getSubscriber()}")
                Calendar cal = Calendar.getInstance()
                List<String> dateFieldKeys = ['startDate','endDate','manualCancellationDate']
                dateFieldKeys.each { String field ->
                    if(sub[field]) {
                        cal.setTime(sub[field])
                        cal.add(Calendar.YEAR, 1)
                        sub[field] = cal.getTime()
                    }
                }
                if(!sub.save(flush:true)) //damn it! But here, it is unavoidable.
                    [sub,sub.errors]
            }
        }
        true
    }
}