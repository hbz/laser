<%@ page import="de.laser.helper.RDStore;de.laser.helper.RDConstants;com.k_int.kbplus.Links;com.k_int.kbplus.GenericOIDService;com.k_int.kbplus.OrgRole;com.k_int.kbplus.RefdataCategory;com.k_int.kbplus.RefdataValue;com.k_int.properties.PropertyDefinition;com.k_int.kbplus.Subscription;com.k_int.kbplus.CostItem" %>
<laser:serviceInjection />

<g:if test="${params.member}">
    <g:set var="chosenOrg" value="${com.k_int.kbplus.Org.findById(params.member)}" />
    <g:set var="chosenOrgCPAs" value="${chosenOrg?.getGeneralContactPersons(false)}" />

    <table class="ui table la-table la-table-small">
        <tbody>
        <tr>
            <td>
                <p>
                    <strong>
                        ${chosenOrg?.name}
                        <g:if test="${chosenOrg?.shortname}">(${chosenOrg?.shortname})</g:if>
                        <g:if test="${chosenOrg.getCustomerType() in ['ORG_INST', 'ORG_INST_COLLECTIVE']}">
                            <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                                  data-content="${chosenOrg.getCustomerTypeI10n()}">
                                <i class="chess rook grey icon"></i>
                            </span>
                        </g:if>
                    </strong>
                </p>
                ${chosenOrg?.libraryType?.getI10n('value')}
            </td>
            <td>
                <g:if test="${chosenOrgCPAs}">
                    <g:each in="${chosenOrgCPAs}" var="gcp">
                        <g:render template="/templates/cpa/person_details" model="${[person: gcp, tmplHideLinkToAddressbook: true, overwriteEditable: false]}" />
                    </g:each>
                </g:if>
            </td>
        </tr>
        </tbody>
    </table>
</g:if>
<g:if test="${entries}">
    <table class="ui celled sortable table table-tworow la-table la-ignore-fixed">
        <thead>
        <tr>
            <th rowspan="2" class="center aligned">${message(code:'sidewide.number')}</th>
            <g:sortableColumn property="roleT.org.sortname" params="${params}" title="${message(code:'myinst.consortiaSubscriptions.member')}" rowspan="2" />
            <g:sortableColumn property="subT.name" params="${params}" title="${message(code:'myinst.consortiaSubscriptions.subscription')}" class="la-smaller-table-head" />
            <th rowspan="2">${message(code:'myinst.consortiaSubscriptions.packages')}</th>
            <th rowspan="2">${message(code:'myinst.consortiaSubscriptions.provider')}</th>
            <th rowspan="2">${message(code:'myinst.consortiaSubscriptions.runningTimes')}</th>
            <g:if test="${'withCostItems' in tableConfig}">
                <th rowspan="2">${message(code:'financials.amountFinal')}</th>
                <th class="la-no-uppercase" rowspan="2">
                    <span  class="la-popup-tooltip la-delay" data-content="${message(code:'financials.costItemConfiguration')}" data-position="left center">
                        <i class="money bill alternate icon"></i>
                    </span>&nbsp;/&nbsp;
                    <span data-position="top right"  class="la-popup-tooltip la-delay" data-content="${message(code:'financials.isVisibleForSubscriber')}" style="margin-left:10px">
                        <i class="ui icon eye orange"></i>
                    </span>
                </th>
            </g:if>

            <th class="la-no-uppercase" rowspan="2" >
                <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                      data-content="${message(code: 'subscription.isMultiYear.consortial.label')}">
                    <i class="map orange icon"></i>
                </span>
            </th>
            <g:if test="${'onlyMemberSubs' in tableConfig}">
                <th rowspan="2" class="la-no-uppercase">${message(code:'default.actions.label')}</th>
            </g:if>
        </tr>
        <g:if test="${'withCostItems' in tableConfig}">
            <tr>
                <%-- sorting over links table is problematic because of complicated join over oid and n:n relation, needs ticket --%>
                <%--<g:sortableColumn property="licenseName" params="${params}" title="${message(code:'license.label')}" class="la-smaller-table-head" />--%>
                <th class="la-smaller-table-head">${message(code:'license.label')}</th>
            </tr>
        </g:if>
        </thead>
        <tbody>
        <g:each in="${entries}" var="entry" status="jj">
            <%
                com.k_int.kbplus.CostItem ci
                com.k_int.kbplus.Subscription subCons
                com.k_int.kbplus.Org subscr
                if('withCostItems' in tableConfig) {
                    ci = entry[0] ?: new CostItem()
                    subCons = entry[1]
                    subscr = entry[2]
                }
                else if('onlyMemberSubs' in tableConfig) {
                    subCons = entry[0]
                    subscr = entry[1]
                }
            %>
            <tr>
                <td>
                    ${ jj + 1 }
                </td>
                <td>
                    <g:link controller="organisation" action="show" id="${subscr.id}">
                        <g:if test="${subscr.sortname}">${subscr.sortname}</g:if>
                        (${subscr.name})
                    </g:link>
                    <g:if test="${OrgRole.findBySubAndOrgAndRoleType(subCons, subscr, RDStore.OR_SUBSCRIBER_CONS_HIDDEN)}">
                        <span data-position="top left" class="la-popup-tooltip la-delay" data-content="${message(code:'financials.isNotVisibleForSubscriber')}">
                            <i class="low vision grey icon"></i>
                        </span>
                    </g:if>
                    <g:if test="${subscr.getCustomerType() in ['ORG_INST', 'ORG_INST_COLLECTIVE']}">
                        <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                              data-content="${subscr.getCustomerTypeI10n()}">
                            <i class="chess rook grey icon"></i>
                        </span>
                    </g:if>

                </td>
                <td>

                    <div class="la-flexbox la-main-object">

                        <i class="icon clipboard outline outline la-list-icon"></i>
                        <g:link controller="subscription" action="show" id="${subCons.id}">${subCons.name}</g:link>
                        <g:if test="${subCons.getCalculatedPrevious()}">
                            <span data-position="top left" class="la-popup-tooltip la-delay" data-content="${message(code:'subscription.hasPreviousSubscription')}">
                                <i class="arrow left grey icon"></i>
                            </span>
                        </g:if>
                    </div>
                    <g:set var="linkedLicenses" value="${Links.findAllByDestinationAndLinkType(GenericOIDService.getOID(subCons),RDStore.LINKTYPE_LICENSE)}"/>
                    <g:each in="${linkedLicenses}" var="link">
                        <g:set var="license" value="${genericOIDService.resolveOID(link.source)}"/>
                        <div class="la-flexbox">
                            <i class="icon balance scale la-list-icon"></i>
                            <g:link controller="license" action="show" id="${license.id}">${license.reference}</g:link><br>
                        </div>
                    </g:each>
                </td>
                <td>
                    <g:each in="${subCons.packages}" var="subPkg">
                        <div class="la-flexbox">
                            <i class="icon gift la-list-icon"></i>
                            <g:link controller="package" action="show" id="${subPkg.pkg.id}">${subPkg.pkg.name}</g:link>
                        </div>
                    </g:each>
                </td>
                <td>
                    <g:each in="${subCons.providers}" var="p">
                        <g:link controller="organisation" action="show" id="${p.id}">${p.getDesignation()}</g:link> <br/>
                    </g:each>
                </td>
                <g:if test="${'withCostItems' in tableConfig}">
                    <td>
                        <g:if test="${ci.id}"> <%-- only existing cost item --%>
                            <g:if test="${ci.getDerivedStartDate()}">
                                <g:formatDate date="${ci.getDerivedStartDate()}" format="${message(code:'default.date.format.notime')}"/>
                                <br />
                            </g:if>
                            <g:if test="${ci.getDerivedEndDate()}">
                                <g:formatDate date="${ci.getDerivedEndDate()}" format="${message(code:'default.date.format.notime')}"/>
                            </g:if>
                        </g:if>
                    </td>
                    <td>
                        <g:if test="${ci.id}"> <%-- only existing cost item --%>
                            <g:formatNumber number="${ci.costInBillingCurrencyAfterTax ?: 0.0}"
                                            type="currency"
                                            currencySymbol="${ci.billingCurrency ?: 'EUR'}" />
                        </g:if>
                    </td>

                    <%  // TODO .. copied from finance/_result_tab_cons.gsp

                    def elementSign = 'notSet'
                    def icon = ''
                    def dataTooltip = ""
                    if (ci.costItemElementConfiguration) {
                        elementSign = ci.costItemElementConfiguration
                    }

                    switch(elementSign) {
                        case RDStore.CIEC_POSITIVE:
                            dataTooltip = message(code:'financials.costItemConfiguration.positive')
                            icon = '<i class="plus green circle icon"></i>'
                            break
                        case RDStore.CIEC_NEGATIVE:
                            dataTooltip = message(code:'financials.costItemConfiguration.negative')
                            icon = '<i class="minus red circle icon"></i>'
                            break
                        case RDStore.CIEC_NEUTRAL:
                            dataTooltip = message(code:'financials.costItemConfiguration.neutral')
                            icon = '<i class="circle yellow icon"></i>'
                            break
                        default:
                            dataTooltip = message(code:'financials.costItemConfiguration.notSet')
                            icon = '<i class="question circle icon"></i>'
                            break
                    }
                    %>

                    <td>
                        <g:if test="${ci.id}">
                            <span data-position="top left"  class="la-popup-tooltip la-delay" data-content="${dataTooltip}">${raw(icon)}</span>
                        </g:if>

                        <g:if test="${ci.isVisibleForSubscriber}">
                            <span data-position="top right"  class="la-popup-tooltip la-delay" data-content="${message(code:'financials.isVisibleForSubscriber')}" style="margin-left:10px">
                                <i class="ui icon eye orange"></i>
                            </span>
                        </g:if>
                    </td>
                </g:if>
                <g:elseif test="${'onlyMemberSubs' in tableConfig}">
                    <td>
                        <g:if test="${subCons.startDate}">
                            <g:formatDate date="${subCons.startDate}" format="${message(code:'default.date.format.notime')}"/>
                            <br />
                        </g:if>
                        <g:if test="${subCons.endDate}">
                            <g:formatDate date="${subCons.endDate}" format="${message(code:'default.date.format.notime')}"/>
                        </g:if>
                    </td>
                </g:elseif>
                <td>
                    <g:if test="${subCons.isMultiYear}">
                        <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                              data-content="${message(code: 'subscription.isMultiYear.consortial.label')}">
                            <i class="map orange icon"></i>
                        </span>
                    </g:if>
                </td>
                <g:if test="${'onlyMemberSubs' in tableConfig}">
                    <td>
                        <g:if test="${subCons in linkedSubscriptions}">
                            <g:link class="ui icon negative button" action="linkToSubscription" params="${params+[id:license.id,unlink:true,subscription:subCons.id]}">
                                <i class="ui minus icon"></i>
                            </g:link>
                        </g:if>
                        <g:else>
                            <g:link class="ui icon positive button" action="linkToSubscription" params="${params+[id:license.id,subscription:subCons.id]}">
                                <i class="ui plus icon"></i>
                            </g:link>
                        </g:else>
                    </td>
                </g:if>
            </tr>
        </g:each>
        </tbody>
        <g:if test="${'withCostItems' in tableConfig}">
            <tfoot>
            <tr>
                <th colspan="8">
                    ${message(code:'financials.totalCostOnPage')}
                </th>
            </tr>
            <g:each in="${finances}" var="entry">
                <tr>
                    <td colspan="6">
                        ${message(code:'financials.sum.billing')} ${entry.key}<br>
                    </td>
                    <td class="la-exposed-bg">
                        <g:formatNumber number="${entry.value}" type="currency" currencySymbol="${entry.key}"/>
                    </td>
                    <td colspan="1">

                    </td>
                </tr>
            </g:each>

            </tfoot>
        </g:if>
    </table>
</g:if>
<g:else>
    <g:if test="${filterSet}">
        <br><strong><g:message code="filter.result.empty"/></strong>
    </g:if>
    <g:else>
        <br><strong><g:message code="result.empty"/></strong>
    </g:else>
</g:else>

<semui:paginate action="${actionName}" controller="${controllerName}" params="${params}"
                next="${message(code:'default.paginate.next')}"
                prev="${message(code:'default.paginate.prev')}"
                max="${max}" total="${totalCount}" />