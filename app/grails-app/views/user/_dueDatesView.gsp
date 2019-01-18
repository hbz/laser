<%@ page import="de.laser.helper.SqlDateUtils; com.k_int.kbplus.*; com.k_int.kbplus.abstract_domain.AbstractProperty" %>
<laser:serviceInjection />
<div>
    <g:set var="dashboard_last_update" value="${de.laser.DashboardDueDate.executeQuery("select max(lastUpdated) from DashboardDueDate ")[0]}" />
    <g:if test="${dashboard_last_update != null}" >
        <g:if test="${ ! SqlDateUtils.isYesterdayOrToday(dashboard_last_update)}"><i class="exclamation triangle icon" ></i></g:if>
        ${message(code:'myinst.dash.due_dates.lastUpdate')}&nbsp<g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${dashboard_last_update}"/>&nbsp
    </g:if>

</div>

    <g:if test="${dueDates}">

        <table class="ui celled table">
            <thead>
                <tr>
                    <th>${message(code:'myinst.dash.due_dates.attribute.label')}</th>
                    <th>${message(code:'myinst.dash.due_date.date.label')}</th>
                    <th>${message(code:'myinst.dash.due_dates.name.label')}</th>
                </tr>
            </thead>
            <tbody>
                <g:each in="${dueDates}" var="dashDueDate">
                    <g:set var="obj" value="${genericOIDService.resolveOID(dashDueDate.oid)}"/>
                    <tr>
                        <td>
                            <g:if test="${obj instanceof AbstractProperty}">
                                <i class="icon tags la-list-icon"></i>
                            </g:if>
                            ${dashDueDate.attribut}
                        </td>
                        <td>
                            <g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${dashDueDate.date}"/>
                            <g:if test="${SqlDateUtils.isToday(dashDueDate.date)}">
                                <span data-tooltip="${message(code:'myinst.dash.due_date.enddate.isDueToday.label')}" data-position="top right">
                                    <i class="icon yellow exclamation"></i>
                                </span>
                            </g:if>
                            <g:elseif test="${SqlDateUtils.isBeforeToday(dashDueDate.date)}">
                                <span data-tooltip="${message(code:'myinst.dash.due_date.enddate.isOverdue.label')}" data-position="top right">
                                    <i class="icon red exclamation"></i>
                                </span>
                            </g:elseif>
                        </td>
                        <td>
                            <div class="la-flexbox">
                                <g:if test="${obj instanceof Subscription}">
                                    <i class="icon folder open la-list-icon"></i>
                                    <g:link controller="subscriptionDetails" action="show" id="${obj.id}">${obj.name}</g:link>
                                </g:if>
                                <g:elseif test="${obj instanceof License}">
                                    <i class="icon balance scale la-list-icon"></i>
                                    <g:link controller="licenseDetails" action="show" id="${obj.id}">${obj.name}</g:link>
                                </g:elseif>
                                <g:elseif test="${obj instanceof Task}">
                                    <span data-position="top right" data-tooltip="Aufgabe">
                                        <i class="icon tasks la-list-icon"></i>
                                    </span>
                                    <a href="#" class="header" onclick="taskedit(${obj?.id});">${obj?.title}</a>
                                    &nbsp(Status: ${obj.status?.getI10n("value")})
                                </g:elseif>
                                <g:elseif test="${obj instanceof AbstractProperty}">
                                    <g:if test="${obj.owner instanceof Person}">
                                        <i class="icon address book la-list-icon"></i>
                                        <g:link controller="person" action="show" id="${obj.owner.id}">${obj.owner?.first_name}&nbsp${obj.owner?.last_name}</g:link>
                                    </g:if>
                                    <g:elseif test="${obj.owner instanceof Subscription}">
                                        <i class="icon folder open la-list-icon"></i>
                                        <g:link controller="subscriptionDetails" action="show" id="${obj.owner?.id}">${obj.owner?.name}</g:link>
                                    </g:elseif>
                                    <g:elseif test="${obj.owner instanceof License}">
                                        <i class="icon balance scale la-list-icon"></i>
                                        <g:link controller="licenseDetails" action="show" id="${obj.owner?.id}">${obj.owner?.reference}</g:link>
                                    </g:elseif>
                                    <g:elseif test="${obj.owner instanceof Org}">
                                        <i class="icon university la-list-icon"></i>
                                        <g:link controller="organisations" action="show" id="${obj.owner?.id}">${obj.owner?.name}</g:link>
                                    </g:elseif>
                                    <g:else>
                                        ${obj.owner?.name}
                                    </g:else>
                                </g:elseif>
                                <g:else>
                                    Not implemented yet!
                                </g:else>
                            </div>
                        </td>
                    </tr>
                </g:each>
            </tbody>
            <tfoot>
                <tr>
                    <td>
                        <semui:paginate offset="${dashboardDueDatesOffset ? dashboardDueDatesOffset : '1'}" max="${contextService.getUser().getDefaultPageSizeTMP()}" params="${[view:'dueDatesView']}" total="${dueDatesCount}"/>
                    </td>
                </tr>
            </tfoot>
        </table>
    </g:if>
    <g:else>
        <g:message code="profile.noDashboardReminderDates" default="In the next {0} days no dates are due!"
                   args="${user?.getSettingsValue(com.k_int.kbplus.UserSettings.KEYS.DASHBOARD_REMINDER_PERIOD, 14)}"/>
    </g:else>
