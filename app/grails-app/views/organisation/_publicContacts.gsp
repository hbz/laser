<%@ page import="de.laser.helper.RDStore; com.k_int.kbplus.PersonRole;" %>
<laser:serviceInjection/>

<g:set var="showOnlyPublic" value="${true}"/>

<div class="ui cards">
<g:if test="${!isProviderOrAgency}">
    <div class="card">
        <div class="content">
            <div class="header">${RDStore.PRS_FUNC_GENERAL_CONTACT_PRS.getI10n('value')}</div>

            <div class="description">

                <g:set var="persons"
                       value="${orgInstance.getContactPersonsByFunctionType(showOnlyPublic, RDStore.PRS_FUNC_GENERAL_CONTACT_PRS)}"/>
                <g:each in="${persons}" var="prs">
                    <g:render template="/templates/cpa/person_full_details" model="${[
                            person                 : prs,
                            personRole             : PersonRole.findByOrgAndFunctionTypeAndPrs(orgInstance, RDStore.PRS_FUNC_GENERAL_CONTACT_PRS, prs),
                            personContext          : orgInstance,
                            tmplShowDeleteButton   : true,
                            tmplShowFunctions      : false,
                            tmplShowPositions      : false,
                            tmplShowResponsiblities: true,
                            tmplConfigShow         : ['E-Mail', 'Mail', 'Url', 'Phone', 'Fax', 'address'],
                            controller             : 'organisation',
                            action                 : 'show',
                            id                     : orgInstance.id,
                            editable               : false,
                            noSelection            : true
                    ]}"/>
                </g:each>
                <g:if test="${!persons}">
                    <g:message code="person.function.notExist" args="[RDStore.PRS_FUNC_GENERAL_CONTACT_PRS.getI10n('value')]"/>
                </g:if>
            </div>
        </div>
    </div>
</g:if>
<g:if test="${!isProviderOrAgency}">
    <div class="card">
        <div class="content">
            <div class="header">${RDStore.PRS_FUNC_FUNC_BILLING_ADDRESS.getI10n('value')}</div>

            <div class="description">
                <g:set var="persons"
                       value="${orgInstance.getContactPersonsByFunctionType(showOnlyPublic, RDStore.PRS_FUNC_FUNC_BILLING_ADDRESS)}"/>
                <g:each in="${persons}" var="prs">
                    <g:render template="/templates/cpa/person_full_details" model="${[
                            person                 : prs,
                            personRole             : PersonRole.findByOrgAndFunctionTypeAndPrs(orgInstance, RDStore.PRS_FUNC_FUNC_BILLING_ADDRESS, prs),
                            personContext          : orgInstance,
                            tmplShowDeleteButton   : true,
                            tmplShowFunctions      : false,
                            tmplShowPositions      : false,
                            tmplShowResponsiblities: true,
                            tmplConfigShow         : ['E-Mail', 'Mail', 'Url', 'Phone', 'Fax', 'address'],
                            controller             : 'organisation',
                            action                 : 'show',
                            id                     : orgInstance.id,
                            editable               : false,
                            noSelection            : true
                    ]}"/>
                </g:each>
                <g:if test="${!persons}">
                    <g:message code="person.function.notExist" args="[RDStore.PRS_FUNC_FUNC_BILLING_ADDRESS.getI10n('value')]"/>
                </g:if>
            </div>
        </div>
    </div>
</g:if>

<div class="card">
    <div class="content">
        <div class="header">${RDStore.PRS_FUNC_TECHNICAL_SUPPORT.getI10n('value')}</div>

        <div class="description">

            <g:set var="persons"
                   value="${orgInstance.getContactPersonsByFunctionType(showOnlyPublic, RDStore.PRS_FUNC_TECHNICAL_SUPPORT)}"/>
            <g:each in="${persons}" var="prs">
                <g:render template="/templates/cpa/person_full_details" model="${[
                        person                 : prs,
                        personRole             : PersonRole.findByOrgAndFunctionTypeAndPrs(orgInstance, RDStore.PRS_FUNC_TECHNICAL_SUPPORT, prs),
                        personContext          : orgInstance,
                        tmplShowDeleteButton   : true,
                        tmplShowFunctions      : false,
                        tmplShowPositions      : false,
                        tmplShowResponsiblities: true,
                        tmplConfigShow         : ['E-Mail', 'Mail', 'Url', 'Phone', 'Fax', 'address'],
                        controller             : 'organisation',
                        action                 : 'show',
                        id                     : orgInstance.id,
                        editable               : false,
                        noSelection            : true
                ]}"/>
            </g:each>
            <g:if test="${!persons}">
                <g:message code="person.function.notExist" args="[RDStore.PRS_FUNC_TECHNICAL_SUPPORT.getI10n('value')]"/>
            </g:if>
        </div>
    </div>
</div>

<g:if test="${!isProviderOrAgency}">
    <div class="card">
        <div class="content">
            <div class="header">${RDStore.PRS_FUNC_RESPONSIBLE_ADMIN.getI10n('value')}</div>

            <div class="description">

                <g:set var="persons"
                       value="${orgInstance.getContactPersonsByFunctionType(showOnlyPublic, RDStore.PRS_FUNC_RESPONSIBLE_ADMIN)}"/>
                <g:each in="${persons}" var="prs">
                    <g:render template="/templates/cpa/person_full_details" model="${[
                            person                 : prs,
                            personRole             : PersonRole.findByOrgAndFunctionTypeAndPrs(orgInstance, RDStore.PRS_FUNC_RESPONSIBLE_ADMIN, prs),
                            personContext          : orgInstance,
                            tmplShowDeleteButton   : true,
                            tmplShowFunctions      : false,
                            tmplShowPositions      : false,
                            tmplShowResponsiblities: true,
                            tmplConfigShow         : ['E-Mail', 'Mail', 'Url', 'Phone', 'Fax', 'address'],
                            controller             : 'organisation',
                            action                 : 'show',
                            id                     : orgInstance.id,
                            editable               : false,
                            noSelection            : true
                    ]}"/>
                </g:each>
                <g:if test="${!persons}">
                    <g:message code="person.function.notExist" args="[RDStore.PRS_FUNC_RESPONSIBLE_ADMIN.getI10n('value')]"/>
                </g:if>
            </div>
        </div>
    </div>
</g:if>
</div>