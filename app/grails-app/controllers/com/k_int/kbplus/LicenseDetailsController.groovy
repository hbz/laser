package com.k_int.kbplus

import grails.converters.*
import grails.plugins.springsecurity.Secured
import grails.converters.*
import org.elasticsearch.groovy.common.xcontent.*
import groovy.xml.MarkupBuilder
import com.k_int.kbplus.auth.*;
import org.codehaus.groovy.grails.plugins.orm.auditable.AuditLogEvent

class LicenseDetailsController {

  def springSecurityService
  def docstoreService
  def ESWrapperService
  def gazetteerService
  def alertsService

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def index() {
    log.debug("licenseDetails id:${params.id}");
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    // result.institution = Org.findByShortcode(params.shortcode)
    result.license = License.get(params.id)

    if ( ! result.license.hasPerm("view",result.user) ) {
      log.debug("return 401....");
      render(status: '401', text:"You do not have permission to view license ${params.id}");
      return
    }

    if ( result.license.isEditableBy(result.user, request) ) {
      result.editable = true
    }
    else {
      result.editable = false
    }

    result
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def links() {
    log.debug("licenseDetails id:${params.id}");
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    // result.institution = Org.findByShortcode(params.shortcode)
    result.license = License.get(params.id)

    if ( ! result.license.hasPerm("view",result.user) ) {
      render status: 401
      return
    }

    result
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def history() {
    log.debug("licenseDetails id:${params.id}");
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    result.license = License.get(params.id)

    if ( ! result.license.hasPerm("view",result.user) ) {
      render status: 401
      return
    }

    result.max = params.max ?: 20;
    result.offset = params.offset ?: 0;

    def qry_params = [result.license.class.name, "${result.license.id}"]
    result.historyLines = AuditLogEvent.executeQuery("select e from AuditLogEvent as e where className=? and persistedObjectId=? order by id desc", qry_params, [max:result.max, offset:result.offset]);
    result.historyLinesTotal = AuditLogEvent.executeQuery("select count(e.id) from AuditLogEvent as e where className=? and persistedObjectId=?",qry_params)[0];

    result
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def notes() {
    log.debug("licenseDetails id:${params.id}");
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    // result.institution = Org.findByShortcode(params.shortcode)
    result.license = License.get(params.id)

    if ( ! result.license.hasPerm("view",result.user) ) {
      render status: 401
      return
    }

    result
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def documents() {
    log.debug("licenseDetails id:${params.id}");
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    // result.institution = Org.findByShortcode(params.shortcode)
    result.license = License.get(params.id)

    if ( ! result.license.hasPerm("view",result.user) ) {
      render status: 401
      return
    }

    result
  }



  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def uploadDocument() {
    log.debug("upload document....");

    def user = User.get(springSecurityService.principal.id)

    def l = License.get(params.licid);

    if ( ! l.hasPerm("edit",result.user) ) {
      render status: 401
      return
    }

    def input_stream = request.getFile("upload_file")?.inputStream
    def original_filename = request.getFile("upload_file")?.originalFilename

    log.debug("uploadDocument ${params} upload file = ${original_filename}");

    if ( l && input_stream ) {
      def docstore_uuid = docstoreService.uploadStream(input_stream, original_filename, params.upload_title)
      log.debug("Docstore uuid is ${docstore_uuid}");

      if ( docstore_uuid ) {
        log.debug("Docstore uuid present (${docstore_uuid}) Saving info");
        def doc_content = new Doc(contentType:1,
                                  uuid: docstore_uuid,
                                  filename: original_filename,
                                  mimeType: request.getFile("upload_file")?.contentType,
                                  title: params.upload_title,
                                  type:RefdataCategory.lookupOrCreate('Document Type',params.doctype)).save()

        def doc_context = new DocContext(license:l,
                                         owner:doc_content,
                                         user: user,
                                         doctype:RefdataCategory.lookupOrCreate('Document Type',params.doctype)).save(flush:true);
      }
    }

    log.debug("Redirecting...");
    redirect controller: 'licenseDetails', action:'index', id:params.licid, fragment:params.fragment
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def deleteDocuments() {
    def ctxlist = []

    log.debug("deleteDocuments ${params}");

    def user = User.get(springSecurityService.principal.id)
    def l = License.get(params.licid);

    if ( ! l.hasPerm("edit",result.user) ) {
      render status: 401
      return
    }

    params.each { p ->
      if (p.key.startsWith('_deleteflag.') ) {
        def docctx_to_delete = p.key.substring(12);
        log.debug("Looking up docctx ${docctx_to_delete} for delete");
        def docctx = DocContext.get(docctx_to_delete)
        docctx.status = RefdataCategory.lookupOrCreate('Document Context Status','Deleted');
      }
    }

    redirect controller: 'licenseDetails', action:'index', params:[shortcode:params.shortcode], id:params.licid, fragment:'docstab'
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def acceptChange() {
    def user = User.get(springSecurityService.principal.id)
    def license = License.get(params.id)

    if ( ! license.hasPerm("edit",user) ) {
      render status: 401
      return
    }

    def pc = PendingChange.get(params.changeid)

    license[pc.updateProperty] = pc.updateValue
    license.save(flush:true)

    expungePendingChange(license, pc);

    redirect controller: 'licenseDetails', action:'index',id:params.id
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def rejectChange() {
    def user = User.get(springSecurityService.principal.id)
    def license = License.get(params.id)

    if ( ! license.hasPerm("edit",user) ) {
      render status: 401
      return
    }

    def pc = PendingChange.get(params.changeid)
    expungePendingChange(license, pc);
    redirect controller: 'licenseDetails', action:'index',id:params.id
  }

  def expungePendingChange(license, pc) {
    log.debug("Expunging pending change, looking up change context doc=${pc.doc?.id}, lic=${license.id}");

    def this_change_ctx = DocContext.findByOwnerAndLicense(pc.doc, license)

    pc.delete(flush:true);

    if ( this_change_ctx ) {
      log.debug("Delete change context between license and change description document");
      this_change_ctx.alert.delete();
      this_change_ctx.delete(flush:true);

      def remaining_contexts = DocContext.findAllByOwner(pc.doc) 
      if ( remaining_contexts.size() == 0 ) {
        log.debug("Change doc has no remaining contexts, delete it");
        pc.doc.delete();
      }
      else {
        log.debug("Change document still referenced by ${remaining_contexts.size()} contexts");
      }
    }
    else {
      log.debug("No change context found");
    }
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def additionalInfo() {
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    result.license = License.get(params.id)
    result
  }

}
