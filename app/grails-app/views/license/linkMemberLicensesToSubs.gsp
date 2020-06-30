<%@ page import="de.laser.helper.RDStore;de.laser.helper.RDConstants;com.k_int.kbplus.OrgRole;com.k_int.kbplus.RefdataCategory;com.k_int.kbplus.RefdataValue;com.k_int.properties.PropertyDefinition;com.k_int.kbplus.Subscription;com.k_int.kbplus.CostItem" %>
<laser:serviceInjection />

<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI">
    <g:set var="entityName" value="${message(code: 'org.label')}"/>
    <title>${message(code: 'laser')} : ${message(code: 'menu.my.consortiaSubscriptions')}</title>
</head>

<body>

<semui:debugInfo>
    <g:render template="/templates/debug/benchMark" model="[debug: benchMark]" />
</semui:debugInfo>

<g:render template="breadcrumb" model="${[ license:license, params:params ]}"/>

<semui:controlButtons>
    <%-- is as placeholder for breaking header --%>
</semui:controlButtons>

<semui:messages data="${flash}"/>

<h1 class="ui icon header la-clear-before la-noMargin-top"><semui:headerIcon />
    <semui:xEditable owner="${license}" field="reference" id="reference"/>
    <semui:totalNumber total="${totalCount}"/>
</h1>

<semui:anualRings object="${license}" controller="license" action="show" navNext="${navNextLicense}" navPrev="${navPrevLicense}"/>

<g:render template="nav" />

<g:render template="/templates/subscription/consortiaSubscriptionFilter"/>
<div class="ui buttons">
    <g:link action="linkToSubscription" class="ui button positive" params="${params+[id:license.id,subscription:"all"]}"><g:message code="license.linkAll"/></g:link>
    <div class="or" data-text="${message(code:'default.or')}"></div>
    <g:link action="linkToSubscription" class="ui button negative" params="${params+[id:license.id,unlink:true,subscription:"all"]}"><g:message code="license.unlinkAll"/></g:link>
</div>
<g:render template="/templates/subscription/consortiaSubscriptionTable"/>

</body>
</html>