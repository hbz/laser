<%@ page import="com.k_int.properties.PropertyDefinition; com.k_int.kbplus.RefdataCategory; com.k_int.kbplus.Org; com.k_int.kbplus.Person; com.k_int.kbplus.PersonRole; com.k_int.kbplus.RefdataValue; de.laser.helper.RDStore; de.laser.helper.RDConstants" %>
<laser:serviceInjection/>
<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI">
    <g:set var="entityName" value="${message(code: 'person.label')}"/>
    <title>${message(code:'laser')} : <g:message code="default.show.label" args="[entityName]"/></title>

</head>
<laser:serviceInjection />
<body>

<semui:breadcrumbs>
    <semui:crumb message="menu.public.all_orgs" controller="organisation" action="index" />
    <g:message code="default.show.label" args="[entityName]" class="active"/>
</semui:breadcrumbs>

<g:set var="personType" value="${!personInstance.contactType || personInstance.contactType?.id == RDStore.CONTACT_TYPE_PERSONAL.id}" />
<br>
<h1 class="ui icon header la-clear-before la-noMargin-top"><semui:headerIcon />
    ${personInstance}
</h1>

<semui:messages data="${flash}"/>

<div class="ui grid">
    <div class="twelve wide column">

        <div class="la-inline-lists">
            <div class="ui card">
                <div class="content">
                    <dl><dt>${RefdataCategory.getByDesc(RDConstants.PERSON_CONTACT_TYPE).getI10n('desc')}</dt>
                        <dd>
                            <semui:xEditableRefData owner="${personInstance}" field="contactType" config="${RDConstants.PERSON_CONTACT_TYPE}"/>

                            <r:script>
                                $('a[data-name=contactType]').on('save', function(e, params) {
                                    window.location.reload()
                                });
                            </r:script>
                        </dd>
                    </dl>

                    <g:if test="${personType}">
                        <dl><dt id="person_title"><g:message code="person.title.label" /></dt>
                            <dd><semui:xEditable owner="${personInstance}" field="title"/></dd>
                        </dl>
                    </g:if>

                    <dl>
                        <dt id="person_last_name">
                            <g:if test="${personType}">
                                <g:message code="person.last_name.label" />
                            </g:if>
                            <g:else>
                                Bezeichnung
                            </g:else>
                        </dt>
                        <dd><semui:xEditable owner="${personInstance}" field="last_name"/></dd>
                    </dl>

                    <g:if test="${personType}">

                        <dl><dt><g:message code="person.first_name.label" /></dt>
                            <dd><semui:xEditable owner="${personInstance}" field="first_name"/></dd></dl>

                        <dl><dt><g:message code="person.middle_name.label" /></dt>
                            <dd><semui:xEditable owner="${personInstance}" field="middle_name"/></dd></dl>

                        <dl><dt><g:message code="person.gender.label" /></dt>
                            <dd><semui:xEditableRefData owner="${personInstance}" field="gender" config="${RDConstants.GENDER}"/></dd>
                        </dl>

                        <%--
                        <dl><dt>${com.k_int.kbplus.RefdataCategory.getByDesc(RDConstants.PERSON_POSITION).getI10n('desc')}</dt>
                            <dd><semui:xEditableRefData owner="${personInstance}" field="roleType"
                                                        config="${RDConstants.PERSON_POSITION}"/></dd></dl>--%>
                    </g:if>
                </div>
            </div><!-- .card -->

            <div class="ui card">
                <div class="content">

                    <dl><dt><g:message code="person.contacts.label"/></dt>
                        <dd>
                            <div class="ui divided middle aligned selection list la-flex-list">
                                <g:each in="${personInstance?.contacts?.toSorted()}" var="c">

                                    <g:render template="/templates/cpa/contact" model="${[
                                            contact: c,
                                            tmplShowDeleteButton: true,
                                            controller: 'person',
                                            action: 'show',
                                            id: personInstance.id
                                    ]}"/>

                                </g:each>
                            </div>
                            <g:if test="${editable}">
                                <input class="ui button" type="button" data-semui="modal" data-href="#contactFormModal"
                                       value="${message(code: 'default.add.label', args: [message(code: 'person.contacts.label')])}">
                                <g:render template="/contact/formModal" model="['prsId': personInstance?.id]"/>
                            </g:if>
                        </dd>
                    </dl>

                    <dl><dt><g:message code="person.addresses.label" /></dt>
                        <dd>
                            <div class="ui divided middle aligned selection list la-flex-list">
                                <g:each in="${personInstance.addresses.sort{it.type?.getI10n('value')}}" var="a">

                                    <g:render template="/templates/cpa/address" model="${[
                                            address: a,
                                            tmplShowDeleteButton: true,
                                            controller: 'person',
                                            action: 'show',
                                            id: personInstance.id
                                    ]}"/>

                                </g:each>
                            </div>
                            <g:if test="${editable}">
                                <input class="ui button" type="button" data-semui="modal" data-href="#addressFormModal"
                                       value="${message(code: 'default.add.label', args: [message(code: 'address.label')])}">
                                <g:render template="/address/formModal" model="['prsId': personInstance?.id]"/>
                            </g:if>
                        </dd>
                    </dl>

                </div>
            </div><!-- .card -->

            <g:if test="${!myPublicContact}">
                <div class="ui card">
                    <div class="content">

                        <dl><dt><g:message code="person.functions.label" /></dt>
                            <dd>
                                <div class="ui divided middle aligned selection list la-flex-list">
                                    <g:each in="${personInstance.roleLinks}" var="link">
                                        <g:if test="${link.functionType}">
                                            <div class="ui item address-details">
                                                <span class="la-popup-tooltip la-delay" data-content="${message(code:'org.label')}" data-position="top right" data-variation="tiny">
                                                    <i class="ui icon university la-list-icon"></i>
                                                </span>

                                                <div class="content la-space-right">
                                                    <div class="header">
                                                        ${link.functionType?.getI10n('value')}
                                                    </div>
                                                    <g:link controller="organisation" action="show" id="${link.org?.id}">${link.org?.name}</g:link>
                                                </div>

                                                <div class="content">
                                                    <g:if test="${editable}">
                                                        <g:set var="oid" value="${link.class.name}:${link.id}" />
                                                        <g:if test="${personInstance.roleLinks?.size() > 1}">
                                                            <div class="ui mini icon buttons">
                                                                <g:link class="ui negative button js-open-confirm-modal"
                                                                        data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.function", args: [link.functionType?.getI10n('value')])}"
                                                                        data-confirm-term-how="delete"
                                                                        controller="person" action="deletePersonRole" id="${personInstance.id}"  params="[oid: oid]">
                                                                    <i class="trash alternate icon"></i>
                                                                </g:link>
                                                            </div>
                                                        </g:if>
                                                        <g:else>
                                                            <div class="ui mini icon buttons">
                                                                <g:link class="ui negative button js-open-confirm-modal"
                                                                        controller="person"
                                                                        action="_delete"
                                                                        id="${personInstance?.id}"
                                                                        params="[previousReferer: request.getHeader('referer')]"
                                                                        data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.org.PrsLinksAndContact.function", args:[link?.functionType?.getI10n('value'), personInstance.toString()])}"
                                                                        data-confirm-term-how="delete">
                                                                    <i class="trash alternate icon"></i>
                                                                </g:link>
                                                                %{--<g:form controller="person" action="_delete" data-confirm-id="${personInstance?.id?.toString()+ '_form'}">--}%
                                                                %{--<g:hiddenField name="id" value="${personInstance?.id}" />--}%
                                                                %{--<div class="ui icon negative button js-open-confirm-modal"--}%
                                                                %{--data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.contact", args: [personInstance?.toString()])}"--}%
                                                                %{--data-confirm-term-how="delete"--}%
                                                                %{--data-confirm-id="${personInstance?.id}" >--}%
                                                                %{--<i class="trash alternate icon"></i>--}%
                                                                %{--</div>--}%
                                                                %{--</g:form>--}%
                                                            </div>
                                                        </g:else>
                                                    </g:if>
                                                </div>
                                            </div>
                                        </g:if>
                                    </g:each>
                                </div>

                                <g:if test="${editable}">
                                    <a href="#prFunctionModal" data-semui="modal" class="ui button">${message('code':'default.button.add.label')}</a>
                                </g:if>
                            </dd>
                        </dl>

                        <dl><dt><g:message code="person.positions.label" /></dt>
                            <dd>
                                <div class="ui divided middle aligned selection list la-flex-list">
                                    <g:each in="${personInstance.roleLinks}" var="link">
                                        <g:if test="${link.positionType}">
                                            <div class="ui item address-details">
                                                <span class="la-popup-tooltip la-delay" data-content="${message(code:'org.label')}" data-position="top right" data-variation="tiny">
                                                    <i class="ui icon university la-list-icon"></i>
                                                </span>

                                                <div class="content la-space-right">
                                                    <div class="header">
                                                        ${link.positionType?.getI10n('value')}
                                                    </div>
                                                    <g:link controller="organisation" action="show" id="${link.org?.id}">${link.org?.name}</g:link>
                                                </div>

                                                <div class="content">
                                                    <g:if test="${editable}">
                                                        <g:set var="oid" value="${link.class.name}:${link.id}" />
                                                        <g:if test="${personInstance.roleLinks?.size() > 1}">
                                                            <div class="ui mini icon buttons">
                                                                <g:link class="ui negative button js-open-confirm-modal"
                                                                        data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.function", args: [link.positionType?.getI10n('value')])}"
                                                                        data-confirm-term-how="unlink"
                                                                        controller="person" action="deletePersonRole" id="${personInstance.id}"  params="[oid: oid]">
                                                                    <i class="unlink icon"></i>
                                                                </g:link>
                                                            </div>
                                                        </g:if>
                                                        <g:else>K
                                                            <div class="ui mini icon buttons">
                                                                <g:link class="ui negative button js-open-confirm-modal"
                                                                        controller="person"
                                                                        action="_delete"
                                                                        id="${personInstance?.id}"
                                                                        params="[previousReferer: request.getHeader('referer')]"
                                                                        data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.org.PrsLinksAndContact.function", args:[link.positionType?.getI10n('value'), personInstance.toString()])}"
                                                                        data-confirm-term-how="delete">
                                                                    <i class="trash alternate icon"></i>
                                                                </g:link>
                                                                %{--<g:form controller="person" action="_delete" data-confirm-id="${personInstance?.id?.toString()+ '_form'}">--}%
                                                                    %{--<g:hiddenField name="id" value="${personInstance?.id}" />--}%
                                                                    %{--<div class="ui icon negative button js-open-confirm-modal"--}%
                                                                         %{--data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.contact", args: [personInstance?.toString()])}"--}%
                                                                         %{--data-confirm-term-how="delete"--}%
                                                                         %{--data-confirm-id="${personInstance?.id}" >--}%
                                                                %{--<i class="trash alternate icon"></i>--}%
                                                                    %{--</div>--}%
                                                                %{--</g:form>--}%
                                                            </div>
                                                        </g:else>
                                                    </g:if>
                                                </div>
                                            </div>
                                        </g:if>
                                    </g:each>
                                </div>

                                <g:if test="${editable}">
                                    <a href="#prPositionModal" data-semui="modal" class="ui button">${message('code':'default.button.add.label')}</a>
                                </g:if>
                            </dd>
                        </dl>

                        <dl><dt><g:message code="person.responsibilites.label" /></dt>
                            <dd>
                                <div class="ui divided middle aligned selection list la-flex-list">
                                    <g:each in="${personInstance.roleLinks}" var="link">
                                        <g:if test="${link.responsibilityType}">
                                            <div class="ui item address-details">

                                                <g:if test="${link.pkg}">
                                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'package.label')}" data-position="top right" data-variation="tiny">
                                                        <i class="ui icon university la-list-icon"></i>
                                                    </span>
                                                </g:if>
                                                <g:if test="${link.cluster}">
                                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'cluster.label')}" data-position="top right" data-variation="tiny">
                                                        <i class="ui icon university la-list-icon"></i>
                                                    </span>
                                                </g:if>
                                                <g:if test="${link.sub}">
                                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'default.subscription.label')}" data-position="top right" data-variation="tiny">
                                                        <i class="ui icon clipboard outline la-list-icon"></i>
                                                    </span>
                                                </g:if>
                                                <g:if test="${link.lic}">
                                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'license.label')}" data-position="top right" data-variation="tiny">
                                                        <i class="ui icon balance scale la-list-icon"></i>
                                                    </span>
                                                </g:if>
                                                <g:if test="${link.title}">
                                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'title.label')}" data-position="top right" data-variation="tiny">
                                                        <i class="ui icon book la-list-icon"></i>
                                                    </span>
                                                </g:if>

                                                <div class="content">
                                                    <div class="header">
                                                        ${link.responsibilityType?.getI10n('value')}
                                                    </div>
                                                    <g:link controller="organisation" action="show" id="${link.org?.id}">${link.org?.name}</g:link>
                                                    <br />

                                                    <g:if test="${link.pkg}">
                                                        <g:link controller="package" action="show" id="${link.pkg.id}">${link.pkg.name}</g:link>
                                                    </g:if>
                                                    <g:if test="${link.cluster}">
                                                        <g:link controller="cluster" action="show" id="${link.cluster.id}">${link.cluster.name}</g:link>
                                                    </g:if>
                                                    <g:if test="${link.sub}">
                                                        <g:link controller="subscription" action="show" id="${link.sub.id}">${link.sub.name}</g:link>
                                                    </g:if>
                                                    <g:if test="${link.lic}">
                                                        <g:link controller="license" action="show" id="${link.lic.id}">${link.lic}</g:link>
                                                    </g:if>
                                                    <g:if test="${link.title}">
                                                        <g:link controller="title" action="show" id="${link.title.id}">${link.title.title}</g:link>
                                                    </g:if>
                                                </div>

                                                <div class="content">
                                                    <g:if test="${editable}">
                                                        <div class="ui mini icon buttons">
                                                            <g:set var="oid" value="${link.class.name}:${link.id}" />
                                                            <g:link class="ui negative button" controller="person" action="deletePersonRole" id="${personInstance.id}" params="[oid: oid]">
                                                                <i class="trash alternate icon"></i>
                                                            </g:link>
                                                        </div>
                                                    </g:if>

                                                </div>

                                            </div>
                                        </g:if>
                                    </g:each>
                                </div>


                                <%--<g:if test="${editable}">
                                    <button class="ui button add-person-role" type="button">${message('code':'default.button.add.label')}</button>
                                </g:if>--%>

                            </dd></dl>

                    </div>
                </div><!-- .card -->
            </g:if>

            <g:javascript src="properties.js"/>
            <div class="ui grid">
                <div class="sixteen wide column">
                    <div class="la-inline-lists">
                        <div class="ui card">
                            <div class="content">
                                <% def org = contextService.getOrg() %>
                                <div id="custom_props_div_${org.id}">
                                    <h5 class="ui header">${message(code:'org.properties.private')} ${org.name}</h5>
                                    <g:render template="../templates/properties/private" model="${[
                                            prop_desc: PropertyDefinition.PRS_PROP,
                                            ownobj: personInstance,
                                            custom_props_div: "custom_props_div_${org.id}",
                                            tenant: org]}"/>
                                    <r:script language="JavaScript">
                                        $(document).ready(function(){
                                            c3po.initProperties("<g:createLink controller='ajax' action='lookup'/>", "#custom_props_div_${org.id}", ${org.id});
                                        });
                                    </r:script>
                                </div>
                            </div>
                        </div><!-- .card -->
                    </div>
                </div>
            </div>

            <g:if test="${personInstance?.tenant && !myPublicContact}">
                <div class="ui card">
                    <div class="content">
                        <dl><dt><g:message code="person.tenant.label" /></dt>
                            <dd>

                                <g:if test="${editable /* && personInstance?.tenant?.id == contextService.getOrg().id */ && personInstance?.isPublic}">
                                    <semui:xEditableRefData owner="${personInstance}" field="tenant"
                                                            dataController="person" dataAction="getPossibleTenantsAsJson" />
                                </g:if>
                                <g:else>
                                    <g:link controller="organisation" action="show"
                                            id="${personInstance.tenant?.id}">${personInstance.tenant}</g:link>
                                </g:else>

                                <g:if test="${! personInstance.isPublic}">
                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'address.private')}" data-position="top right">
                                        <i class="address card outline icon"></i>
                                    </span>
                                    * Kann nicht geändert werden.
                                </g:if>
                                <g:else>
                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'address.public')}" data-position="top right">
                                        <i class="address card icon"></i>
                                    </span>
                                </g:else>

                            </dd></dl>
                    </div>
                </div><!-- .card -->
            </g:if>
            <g:if test="${editable && personInstance?.tenant?.id == contextService.getOrg().id}">
                <div class="ui card">
                    <div class="content">
                            <g:link controller="person"
                                    action="_delete"
                                    id="${personInstance?.id}"
                                    data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.contact", args: [personInstance])}"
                                    data-confirm-term-how="delete"
                                    class="ui icon negative button js-open-confirm-modal"
                                    params="[previousReferer: request.getHeader('referer')]">
                                ${message(code: 'default.delete.label', args: ["${message(code: 'person')}"])}
                            </g:link>
                    </div>
                </div>
            </g:if>

        </div>

    </div><!-- .twelve -->

    <aside class="four wide column">
    </aside><!-- .four -->

</div><!-- .grid -->

<g:render template="prsRoleModal" model="[
        tmplId: 'prFunctionModal',
        tmplRoleType: 'Funktion',
        roleType: PersonRole.TYPE_FUNCTION,
        roleTypeValues: PersonRole.getAllRefdataValues(RDConstants.PERSON_FUNCTION),
        message:'person.function_new.label',
        presetOrgId: presetOrg?.id]" />

<g:render template="prsRoleModal" model="[
        tmplId: 'prPositionModal',
        tmplRoleType: 'Position',
        roleType: PersonRole.TYPE_POSITION,
        roleTypeValues: PersonRole.getAllRefdataValues(RDConstants.PERSON_POSITION),
        message:'person.position_new.label',
        presetOrgId: presetOrg?.id]" />

</body>
</html>
