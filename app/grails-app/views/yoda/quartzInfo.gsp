<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI">
    <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'menu.yoda.quartzInfo')}</title>
</head>
<body>

<semui:breadcrumbs>
    <semui:crumb message="menu.yoda.dash" controller="yoda" action="index"/>
    <semui:crumb message="menu.yoda.quartzInfo" class="active"/>
</semui:breadcrumbs>

<h1 class="ui left aligned icon header"><semui:headerIcon />${message(code:'menu.yoda.quartzInfo')}</h1>

<g:each in="${quartz}" var="groupKey, group">
    <h3 class="ui header">${groupKey}</h3>

    <table class="ui celled la-table la-table-small table">
        <thead>
            <tr>
                <th>Job</th>
                <th>Config</th>
                <th>s  m  h  DoM  M  DoW  Y</th>
                <th>Status</th>
                <th>Nächste Ausführung</th>
            </tr>
        </thead>
        <tbody>
            <g:each in="${group}" var="job">
                <tr>
                    <td>
                        ${job.name}
                    </td>
                    <td>
                        <g:each in="${job.configFlags.split(',')}" var="flag">
                            <g:if test="${currentConfig.get(flag) && currentConfig.get(flag) != false}">
                                ${flag}
                            </g:if>
                            <g:else>
                                <span style="color:lightgrey;font-style:italic">${flag}</span>
                            </g:else>
                        </g:each>
                    </td>
                    <td>
                        <code>${job.cronEx}</code>
                    </td>
                    <td>
                        <g:if test="${job.isRunning}">
                            <i class="ui icon circle green"></i>
                        </g:if>
                        <g:else>
                            <i class="ui icon circle outline grey"></i>
                        </g:else>
                    </td>
                    <td>
                        <%
                            boolean isActive = true
                            job.configFlags.split(',').each { flag ->
                                flag = flag.trim()
                                isActive = isActive && (currentConfig.get(flag) && currentConfig.get(flag) != false)
                            }
                        %>
                        <g:if test="${isActive}">
                            ${job.nextFireTime}
                        </g:if>
                        <g:else>
                            <span style="color:lightgrey">${job.nextFireTime}</span>
                        </g:else>
                        <%--<g:formatDate format="${message(code:'default.date.format.noZ')}" date="${job.nextFireTime}" />--%>
                    </td>
                </tr>
            </g:each>
        </tbody>
    </table>
</g:each>

<br />
<br />

</body>
</html>