package de.laser.api.v0

import com.k_int.kbplus.*
import com.k_int.kbplus.auth.User
import de.laser.api.v0.catalogue.ApiRefdatas
import de.laser.api.v0.entities.*
import de.laser.helper.Constants
import grails.converters.JSON
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.util.logging.Log4j
import org.codehaus.groovy.grails.web.json.JSONObject
import org.springframework.http.HttpStatus

import javax.servlet.http.HttpServletRequest

@Log4j
class ApiManager {

    static final VERSION = 'Variant 0 :: Version 0.16'
    static final NOT_SUPPORTED = false

    /**
     * @return Object
     * @return BAD_REQUEST: if invalid/missing (unsupported) identifier
     * @return PRECONDITION_FAILED: if multiple matches(objects) are found
     * @return NOT_ACCEPTABLE: if requested format(response) is not supported
     * @return NOT_IMPLEMENTED: if requested method(object type) is not supported
     */
    static read(String obj, String query, String value, User user, Org contextOrg, String format) {
        def result

        def failureCodes  = [Constants.HTTP_BAD_REQUEST, Constants.HTTP_PRECONDITION_FAILED]
        def accessDueDatamanager = ApiReader.isDataManager(user)

        log.debug("API-READ: ${obj} (${format}) @ ${query}:${value}")

        if ('document'.equalsIgnoreCase(obj)) {
            //if (format in ApiReader.SUPPORTED_FORMATS.document) {
                result = ApiDoc.findDocumentBy(query, value)
                if (result && !(result in failureCodes)) {
                    result = ApiDoc.getDocument((Doc) result, contextOrg, accessDueDatamanager)
                }
            //}
        }
        else if (NOT_SUPPORTED && 'issueEntitlements'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.issueEntitlements) {
                def subPkg = ApiIssueEntitlement.findSubscriptionPackageBy(query, value)
                if (subPkg && !(subPkg in failureCodes) ) {
                    result = ApiIssueEntitlement.getIssueEntitlements(subPkg, contextOrg, accessDueDatamanager)

                    if (result && format == Constants.MIME_TEXT_PLAIN) {
                        def kbart = ApiKbartConverter.convertIssueEntitlements(result)
                        result = ApiKbartConverter.getAsDocument(kbart)
                    }
                }
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else if (NOT_SUPPORTED && 'license'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.license) {
                result = ApiLicense.findLicenseBy(query, value)

                if (result && !(result in failureCodes)) {
                    result = ApiLicense.getLicense((License) result, contextOrg, accessDueDatamanager)
                }
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else if (NOT_SUPPORTED && 'onixpl'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.onixpl) {
                def lic = ApiLicense.findLicenseBy(query, value)

                if (lic && !(lic in failureCodes)) {
                    result = ApiDoc.getOnixPlDocument((License) lic, contextOrg, accessDueDatamanager)
                }
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else if (NOT_SUPPORTED && 'organisation'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.organisation) {
                result = ApiOrg.findOrganisationBy(query, value)

                if (result && !(result in failureCodes)) {
                    result = ApiOrg.getOrganisation((Org) result, contextOrg, accessDueDatamanager)
                }
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else if (NOT_SUPPORTED && 'package'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.package) {
                result = ApiPkg.findPackageBy(query, value)

                if (result && !(result in failureCodes)) {
                    result = ApiPkg.getPackage((Package) result, contextOrg, accessDueDatamanager)
                }
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else if ('refdatas'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.refdatas) {
                result = ApiRefdatas.getAllRefdatas()
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else if ('subscription'.equalsIgnoreCase(obj)) {
            if (format in ApiReader.SUPPORTED_FORMATS.subscription) {
                result = ApiSubscription.findSubscriptionBy(query, value)

                if (result && !(result in failureCodes)) {
                    result = ApiSubscription.getSubscription((Subscription) result, contextOrg, accessDueDatamanager)
                }
            }
            else {
                return Constants.HTTP_NOT_ACCEPTABLE
            }
        }
        else {
            result = Constants.HTTP_NOT_IMPLEMENTED
        }

        result
    }

    @Deprecated
    static write(String obj, JSONObject data, User user, Org contextOrg) {
        def result

        // check existing resources
        def conflict = false

        if (NOT_SUPPORTED && 'organisation'.equalsIgnoreCase(obj)) {

            data.identifiers?.each { ident ->
                def hits = ApiOrg.findOrganisationBy('ns:identifier', ident.namespace + ":" + ident.value)
                if (hits == Constants.HTTP_PRECONDITION_FAILED || hits instanceof Org) {
                    conflict = true
                }
            }
            def hits = ApiOrg.findOrganisationBy('name', data.name.trim())
            if (hits == Constants.HTTP_PRECONDITION_FAILED || hits instanceof Org) {
                conflict = true
            }

            if (conflict) {
                return ['result': Constants.HTTP_CONFLICT, 'debug': 'debug']
            }

            result = ApiWriter.importOrganisation(data, contextOrg)
        }
        else if (NOT_SUPPORTED && 'license'.equalsIgnoreCase(obj)) {

            result = ApiWriter.importLicense(data, contextOrg)
        }
        else if (NOT_SUPPORTED && 'subscription'.equalsIgnoreCase(obj)) {

            data.identifiers?.each { ident ->
                def hits = ApiSubscription.findSubscriptionBy('ns:identifier', ident.namespace + ":" + ident.value)
                if (hits == Constants.HTTP_PRECONDITION_FAILED || hits instanceof Subscription) {
                    conflict = true
                }
            }
            def hits = ApiSubscription.findSubscriptionBy('identifier', data.identifier)
            if (hits == Constants.HTTP_PRECONDITION_FAILED || hits instanceof Subscription) {
                conflict = true
            }

            if (conflict) {
                return ['result': Constants.HTTP_CONFLICT, 'debug': 'debug']
            }

            result = ApiWriter.importSubscription(data, contextOrg)
        }
        else {
            result = Constants.HTTP_NOT_IMPLEMENTED
        }
        result
    }

    static buildResponse(HttpServletRequest request, def obj, def query, def value, def context, def contextOrg, def result) {

        def response = []

        // POST

        if (result instanceof HashMap) {

            switch(result['result']) {
                case Constants.HTTP_CREATED:
                    response << new JSON(["message": "resource successfully created", "debug": result['debug']])
                    response << HttpStatus.CREATED.value()
                    break
                case Constants.HTTP_CONFLICT:
                    response << new JSON(["message": "conflict with existing resource", "debug": result['debug']])
                    response << HttpStatus.CONFLICT.value()
                    break
                case Constants.HTTP_INTERNAL_SERVER_ERROR:
                    response << new JSON(["message": "resource not created", "debug": result['debug']])
                    response << HttpStatus.INTERNAL_SERVER_ERROR.value()
                    break
            }
        }

        // GET

        else if (Constants.HTTP_FORBIDDEN == result) {
            if (contextOrg) {
                response << new JSON(["message": "forbidden", "obj": obj, "q": query, "v": value, "context": contextOrg.shortcode])
                response << HttpStatus.FORBIDDEN.value()
            }
            else {
                response << new JSON(["message": "forbidden", "obj": obj, "context": context])
                response << HttpStatus.FORBIDDEN.value()
            }
        }
        else if (Constants.HTTP_NOT_ACCEPTABLE == result) {
            response << new JSON(["message": "requested format not supported", "method": request.method, "accept": request.getHeader('accept'), "obj": obj])
            response << HttpStatus.NOT_ACCEPTABLE.value()
        }
        else if (Constants.HTTP_NOT_IMPLEMENTED == result) {
            response << new JSON(["message": "requested method not implemented", "method": request.method, "obj": obj])
            response << HttpStatus.NOT_IMPLEMENTED.value()
        }
        else if (Constants.HTTP_BAD_REQUEST == result) {
            response << new JSON(["message": "invalid/missing identifier or post body", "obj": obj, "q": query, "context": context])
            response << HttpStatus.BAD_REQUEST.value()
        }
        else if (Constants.HTTP_PRECONDITION_FAILED == result) {
            response << new JSON(["message": "precondition failed; multiple matches", "obj": obj, "q": query, "context": context])
            response << HttpStatus.PRECONDITION_FAILED.value()
        }

        if (! result) {
            response << new JSON(["message": "object not found", "obj": obj, "q": query, "v": value, "context": context])
            response << HttpStatus.NOT_FOUND.value()
        }
        else {
            if (result instanceof List) {
                response << new JSON(result)
            }
            else {
                response << result
            }
            response << HttpStatus.OK.value()
        }

        response
    }
}
